const functions = require('@google-cloud/functions-framework');
const sgMail = require('@sendgrid/mail');
const Joi = require('joi');
const { config } = require('./config');

functions.cloudEvent('sendEmail', async (cloudEvent) => {
  console.log('received cloudEvent', cloudEvent);

  const messageData = validateMessageData(cloudEvent);

  console.log('messageData', messageData);

  sgMail.setApiKey(config.sendgridApiKey);

  const msg = {
    to: messageData.to,
    from: config.emailFrom,
    subject: messageData.subject,
    html: messageData.body,
  };

  await sgMail.send(msg);

  console.log('email sent!', msg);
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
    body: validatedMessageData.html,
  };
}
