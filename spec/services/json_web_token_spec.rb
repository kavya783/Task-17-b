require "rails_helper"

RSpec.describe JsonWebToken do

  describe ".encode" do

    it "generates token" do

      token = JsonWebToken.encode(
        user_id: 1
      )

      expect(token).to be_present

    end

  end


  describe ".decode" do

    it "decodes valid token" do

      token = JsonWebToken.encode(
        user_id: 1
      )

      decoded = JsonWebToken.decode(token)

      expect(decoded[:user_id])
        .to eq(1)

    end


    it "returns nil for invalid token" do

      result = JsonWebToken.decode(
        "invalid_token"
      )

      expect(result)
        .to be_nil

    end


  end

end