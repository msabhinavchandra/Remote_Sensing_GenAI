const express = require("express");
const bodyParser = require("body-parser");
const dotenv = require("dotenv");
const cors = require("cors");
const ort = require("onnxruntime-node");
const fs = require("fs");
const path = require("path");
const { Buffer } = require("buffer");
const sharp = require("sharp"); // For image processing
// const axios = require("axios"); // For making HTTP requests

// Load environment variables from the .env file
dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

// Twilio credentials from environment variables
const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const verifyServiceSid = process.env.TWILIO_VERIFY_SERVICE_SID;

// Enable CORS for cross-origin requests
app.use(cors());
app.use(bodyParser.json({ limit: "50mb" })); // Adjust payload size limit for larger images
app.use(bodyParser.json());
// Load ONNX models
const modelPath = path.join(__dirname, "modelSpecNew.onnx"); // Path to existing ONNX model
const pix2pixmodelPath = path.join(__dirname, "Colorize.onnx"); // Path to SAR2RGB ONNX model

let session;
let sarSession;

async function loadModel() {
  try {
    session = await ort.InferenceSession.create(modelPath);
    console.log("ONNX model loaded successfully");
  } catch (error) {
    console.error("Error loading ONNX model:", error);
  }
}
async function loadSarModel() {
  try {
    sarSession = await ort.InferenceSession.create(pix2pixmodelPath);
    console.log("SAR colorization model loaded successfully");
  } catch (error) {
    console.error("Error loading SAR model:", error);
  }
}

loadModel();
loadSarModel();

// Existing image preprocessing function
async function preprocessImage(imageBuffer) {
  try {
    // Load the image and resize it to 224x224 pixels
    const { data, info } = await sharp(imageBuffer)
      .resize(224, 224)
      .raw()
      .toBuffer({ resolveWithObject: true });

    const { width, height, channels } = info;

    if (channels !== 3) {
      throw new Error("Image must have 3 channels (RGB)");
    }

    // Define normalization parameters (same as in PyTorch)
    const mean = [0.485, 0.456, 0.406];
    const std = [0.229, 0.224, 0.225];

    // Create a Float32Array to hold the normalized data
    const chwData = new Float32Array(width * height * channels);

    // Rearrange and normalize the data from HWC to CHW format
    for (let c = 0; c < channels; c++) {
      for (let h = 0; h < height; h++) {
        for (let w = 0; w < width; w++) {
          const hwcIndex = h * width * channels + w * channels + c; // Index in HWC format
          const chwIndex = c * width * height + h * width + w; // Index in CHW format

          // Normalize the pixel value
          const value = data[hwcIndex] / 255.0; // Scale to [0, 1]
          chwData[chwIndex] = (value - mean[c]) / std[c]; // Apply normalization
        }
      }
    }

    // Create the tensor with the correct shape [1, 3, 224, 224]
    const tensor = new ort.Tensor("float32", chwData, [1, 3, height, width]);

    return tensor;
  } catch (error) {
    console.error("Error preprocessing image:", error);
    throw new Error("Image preprocessing failed");
  }
}

// Existing inference function
async function runModel(imageTensor) {
  try {
    const feeds = { [session.inputNames[0]]: imageTensor }; // Use actual input name
    const output = await session.run(feeds);
    const outputTensor = output[session.outputNames[0]]; // Use actual output name

    // Get the predicted class index
    const scores = outputTensor.data;
    const predictedIndex = scores.indexOf(Math.max(...scores));

    const crops = ["jute", "maize", "rice", "sugarcane", "wheat"];
    return crops[predictedIndex];
  } catch (error) {
    console.error("Error running model:", error);
    throw new Error("Model inference failed");
  }
}

// Endpoint for predicting crop type
app.post("/predict", async (req, res) => {
  const base64Image = req.body.image;
  if (!base64Image) {
    return res.status(400).send("No image provided");
  }

  try {
    // Decode Base64 image
    const imageBuffer = Buffer.from(base64Image, "base64");
    console.log("Image received, processing..."); // Debugging line

    // Preprocess image and run model
    const imageTensor = await preprocessImage(imageBuffer);
    const prediction = await runModel(imageTensor);

    // Return prediction
    res.status(200).send({ crop: prediction });
  } catch (error) {
    console.error("Error in /predict route:", error);
    res.status(500).send({ error: error.message });
  }
});

// New functions for SAR2RGB model

// Preprocess SAR image

async function preprocessSarImage(imageBuffer) {
  try {
    // Resize the image to the required dimensions (e.g., 256x256)
    const { data: resizedImageBuffer, info } = await sharp(imageBuffer)
      .resize(256, 256, { fit: "fill" }) // Resize to 256x256 as expected by the model
      .removeAlpha() // Ensure no alpha channel, only RGB
      .raw() // Get raw pixel data
      .toBuffer({ resolveWithObject: true });

    const { width, height, channels } = info;

    if (channels !== 3) {
      throw new Error("Expected image with 3 channels (RGB)");
    }

    // Prepare normalized CHW data
    const chwData = new Float32Array(width * height * channels);
    const mean = [0.5, 0.5, 0.5]; // Pix2Pix normalization (mean and std are 0.5)
    const std = [0.5, 0.5, 0.5];

    for (let c = 0; c < channels; c++) {
      for (let h = 0; h < height; h++) {
        for (let w = 0; w < width; w++) {
          const hwcIndex = h * width * channels + w * channels + c; // Index in HWC format
          const chwIndex = c * width * height + h * width + w; // Index in CHW format
          const value = resizedImageBuffer[hwcIndex] / 255.0; // Scale pixel to [0, 1]
          chwData[chwIndex] = (value - mean[c]) / std[c]; // Normalize
        }
      }
    }

    // Create a tensor in the shape [1, 3, 256, 256]
    const tensor = new ort.Tensor("float32", chwData, [1, 3, height, width]);
    return tensor;
  } catch (error) {
    console.error("Error preprocessing image:", error.message);
    throw new Error("Preprocessing failed");
  }
}

// module.exports = preprocessSarImage;


// module.exports = preprocessSarImage;

// Run SAR2RGB model
async function runSar2RgbModel(imageTensor) {
  try {
    console.log("Input Tensor Shape:", imageTensor.dims); // Log input tensor shape
    console.log(
      "Input Tensor Data (first 10 values):",
      imageTensor.data.slice(0, 10)
    ); // Log first few values
    const feeds = { [sar2rgbSession.inputNames[0]]: imageTensor };
    const output = await sar2rgbSession.run(feeds);
    const outputTensor = output[sar2rgbSession.outputNames[0]];

    return outputTensor;
  } catch (error) {
    console.error("Error running SAR2RGB model:", error);
    throw new Error("SAR2RGB model inference failed");
  }
}

// Postprocess generated image
async function postprocessSarImage(outputTensor) {
  const [_, channels, height, width] = outputTensor.dims;
  const data = outputTensor.data; // Flattened output array

  const chwData = new Uint8Array(width * height * channels);

  for (let c = 0; c < channels; c++) {
    for (let h = 0; h < height; h++) {
      for (let w = 0; w < width; w++) {
        const chwIndex = c * width * height + h * width + w;
        const hwcIndex = h * width * channels + w * channels + c;
        // Denormalize pixel values and clip to [0, 255]
        chwData[hwcIndex] = Math.min(
          Math.max((data[chwIndex] * 0.5 + 0.5) * 255, 0),
          255
        );
      }
    }
  }

  // Convert to an image buffer
  const imageBuffer = Buffer.from(chwData);
  const image = await sharp(imageBuffer, {
    raw: { width, height, channels },
  })
    .toFormat("png") // Convert to PNG
    .toBuffer();

  return image;
}

// Endpoint for colorizing SAR image
app.post("/colorize", async (req, res) => {
  const base64Image = req.body.image;
  if (!base64Image) {
    return res.status(400).send("No image provided");
  }

  try {
    const imageBuffer = Buffer.from(base64Image, "base64");
    console.log("SAR image received, processing...");

    // Preprocess the SAR image
    const imageTensor = await preprocessSarImage(imageBuffer); // Adjust size as needed
    const feeds = { [sarSession.inputNames[0]]: imageTensor };

    // Run inference
    const output = await sarSession.run(feeds);
    const sarOutputTensor = output[sarSession.outputNames[0]];

    // Postprocess the output to get Base64 image
    const colorizedImage = await postprocessSarImage(sarOutputTensor); // Use actual dimensions

    const colorizedBase64 = colorizedImage.toString("base64");
    res.status(200).send({ colorizedImage: colorizedBase64 });
  } catch (error) {
    console.error("Error in /colorize route:", error);
    res.status(500).send({ error: error.message });
  }
});

// Parse incoming JSON requests
app.use(bodyParser.json());

app.get("/", (req, res) => {
  res.send("Hello, World! The server is running.");
});

// Endpoint to send OTP via SMS using Twilio Verify API with Axios
app.post("/send-otp", async (req, res) => {
  const { phoneNumber } = req.body;

  const url = `https://verify.twilio.com/v2/Services/${verifyServiceSid}/Verifications`;

  const data = new URLSearchParams({
    To: phoneNumber,
    Channel: "sms",
  });

  const auth = {
    username: accountSid,
    password: authToken,
  };

  try {
    const response = await axios.post(url, data.toString(), {
      auth,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    });

    res.status(200).send({ sid: response.data.sid });
  } catch (error) {
    console.error("Error sending OTP:", error.response?.data || error.message);
    res.status(500).send({ error: error.message });
  }
});

// Endpoint to verify OTP using Twilio Verify API with Axios
app.post("/verify-otp", async (req, res) => {
  const { phoneNumber, otp } = req.body;

  const url = `https://verify.twilio.com/v2/Services/${verifyServiceSid}/VerificationCheck`;

  const data = new URLSearchParams({
    To: phoneNumber,
    Code: otp,
  });

  const auth = {
    username: accountSid,
    password: authToken,
  };

  try {
    const response = await axios.post(url, data.toString(), {
      auth,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    });

    const verificationCheck = response.data;
    if (verificationCheck.status === "approved") {
      res.status(200).send({ message: "OTP verified successfully" });
    } else {
      res.status(400).send({ message: "Invalid OTP" });
    }
  } catch (error) {
    console.error(
      "Error verifying OTP:",
      error.response?.data || error.message
    );
    res.status(500).send({ error: error.message });
  }
});

// Use HTTP for debugging
app.listen(port, "0.0.0.0", () => {
  console.log(`Server running on http://${process.env.SERVER_IP}:${port}`);
});
