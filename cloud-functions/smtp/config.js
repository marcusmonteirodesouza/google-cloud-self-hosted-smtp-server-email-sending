const Joi = require('joi');

const envVarsSchema = Joi.object()
  .keys({
    EMAIL_FROM: Joi.string().email().required(),
    EMAIL_PASSWORD: Joi.string().required(),
    EMAIL_SERVER_HOST: Joi.string().required(),
  })
  .unknown(true);

const { value: envVars, error } = envVarsSchema.validate(process.env);

if (error) {
  throw error;
}

const config = {
  emailFrom: envVars.EMAIL_FROM,
  emailPassword: envVars.EMAIL_PASSWORD,
  emailServerHost: envVars.EMAIL_SERVER_HOST,
};

module.exports = { config };
