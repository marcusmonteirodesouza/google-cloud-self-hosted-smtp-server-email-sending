const Joi = require('joi');

const envVarsSchema = Joi.object()
  .keys({
    EMAIL_FROM: Joi.string().email().required(),
    SENDGRID_API_KEY: Joi.string().required(),
  })
  .unknown(true);

const { value: envVars, error } = envVarsSchema.validate(process.env);

if (error) {
  throw error;
}

const config = {
  emailFrom: envVars.EMAIL_FROM,
  sendgridApiKey: envVars.SENDGRID_API_KEY,
};

module.exports = { config };
