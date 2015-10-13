
xml.instruct! :xml, version: "1.0", encoding: "UTF-8"

xml.tag!("cas:serviceReponse", "xmlns:cas" => "http://www.yale.edu/tp/cas") do
  if @success
    xml.tag!("cas:authenticationSuccess") do
 end
end
