require_relative "environment"

module Config
	class IEnvironment
		def self.getEnvironment(); environment = Environment.Sandbox; end
		def self.setEnvironment(value); environment = value; end
	end

	class SecretKey
		def self.setSecretKey(value); secretKey = value; end
	end

	class PublicKey
		def self.setPublicKey(value); publicKey = value; end
	end


	def self.initialise(environment, secretKey, publicKey)
		IEnvironment.setEnvironment(environment)
		SecretKey.setSecretKey(secretKey)
		PublicKey.setPublicKey(publicKey)
	end

	def self.baseURL()
		if IEnvironment.getEnvironment == Environment.Sandbox
			return "https://api-sandbox.paydock.com/v1/"
		else
			return "https://api.paydock.com/v1/"
		end
	end
end