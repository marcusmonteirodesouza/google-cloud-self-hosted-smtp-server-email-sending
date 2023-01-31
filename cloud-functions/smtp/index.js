const functions = require('@google-cloud/functions-framework');
const nodemailer = require('nodemailer');
const Joi = require('joi');
const { config } = require('./config');

functions.cloudEvent('sendEmail', async (cloudEvent) => {
  console.log('received cloudEvent', cloudEvent);

  const messageData = validateMessageData(cloudEvent);

  console.log('messageData', messageData);

  const transporter = nodemailer.createTransport({
    host: config.emailServerHost,
    port: 465,
    secure: true,
    auth: {
      user: config.emailFrom,
      pass: config.emailPassword,
    },
  });

  const emailOptions = {
    from: config.emailFrom,
    to: messageData.to,
    subject: messageData.subject,
    html: messageData.body,
  };

  const sentMessageInfo = await transporter.sendMail(emailOptions);

  console.log('email sent!', sentMessageInfo);
});

function validateMessageData(cloudEvent) {
  const base64MessageData = cloudEvent.data.message.data;

  const decodedMessageData = Buffer.from(
    base64MessageData,
    'base64'
  ).toString();

  const parsedMessageData = JSON.parse(decodedMessageData);

  const messageDataSchema = Joi.object().keys({
    to: Joi.string().email().required(),
    subject: Joi.string().required(),
    body: Joi.string().required(),
  });

  const { value: validatedMessageData, error } =
    messageDataSchema.validate(parsedMessageData);

  if (error) {
    throw error;
  }

  return {
    to: validatedMessageData.to,
    subject: validatedMessageData.subject,
    body: validatedMessageData.body,
  };
}
