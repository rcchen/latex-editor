require 'json'
require 'sinatra'
require 'tempfile'

get '/' do
    send_file File.expand_path('index.html', settings.public_folder)
end

get '/file/:uuid' do
    send_file File.expand_path('tmp/' + params[:uuid] + '.pdf', settings.public_folder)
end

post '/render' do

    # Representations of the file
    filename = SecureRandom.uuid
    filename_tex = filename + ".tex"
    filename_pdf = filename + ".pdf"
    

    # Write data to a .tex file
    file = File.new(filename_tex, "w")
    file.puts(params[:data])
    file.close
    
    # Run it through pdflatex and capture the output
    output = `pdflatex -interaction=nonstopmode #{filename_tex}`
    
    # Start creating the response hash
    resp = Hash.new
    resp[:output] = output

    # Check to see if the PDF exists
    resp[:success] = File.file?(filename_pdf)
    if File.file?(filename_pdf)
        `mv #{filename_pdf} public/tmp`
        File.delete(filename + ".*")
        resp[:url] = filename_pdf
    end

    # Return packaged JSON response
    resp.to_json

end
