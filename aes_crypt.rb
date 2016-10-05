require 'openssl'

module AESCrypt
  def AESCrypt.decrypt(encrypted_data, key, iv, cipher_type)
    aes = OpenSSL::Cipher::Cipher.new(cipher_type)
    aes.decrypt
    aes.key = key
    aes.iv = iv if iv != nil
    aes.update([encrypted_data].pack("H*")) + aes.final
  end

  def AESCrypt.encrypt(data, key, iv, cipher_type)
    aes = OpenSSL::Cipher::Cipher.new(cipher_type)
    aes.encrypt
    aes.key = key
    aes.iv = iv if iv != nil
    (aes.update(data) + aes.final).unpack("H*")[0]
  end
end