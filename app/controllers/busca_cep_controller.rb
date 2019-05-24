class BuscaCepController < ApplicationController
    require 'net/http'
    require 'json'
    def buscar
        
        @cep = cep_params[:cep]
        

        url = "https://viacep.com.br/ws/#{@cep}/json/"
        retorno = JSON.parse(Net::HTTP.get(URI(url)))
    
        if retorno["erro"]
            render json: {erro: "CEP não existe"}, status: :ok
        else
            
            estado = Estado.find_or_initialize_by(uf: retorno["uf"])
            estado.save

            cidade = Cidade.find_or_initialize_by(nome: retorno["localidade"], estado: estado)
            cidade.save

            endereco = Endereco.find_or_initialize_by(cep: retorno["cep"])
            endereco.cep = retorno["cep"]
            endereco.logradouro = retorno["logradouro"]
            endereco.bairro = retorno["bairro"]
            endereco.complemento =retorno["complemento"]
            endereco.cidade = cidade
            endereco.save

            render json: endereco.to_json, status: :ok 
        end
    rescue JSON::ParserError =>exception
        render json:{erro: "o cep é invalido"}, status: :ok
        
    rescue=> exception
        
        render json:{erro: "ligar no suporte"}, status: :ok
    
    end

    private 
    def cep_params
        params.permit(:cep)
    end

end
