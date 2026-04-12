const fs = require('fs');
const pdf = require('pdf-parse');
let dataBuffer = fs.readFileSync('c:\\Users\\nesto\\OneDrive\\Documentos\\automatizacion\\Antigravity\\Desarrollos\\Forecast\\documents\\DANE-webservice-SIPSA.pdf');
pdf(dataBuffer).then(function(data) {
  fs.writeFileSync('DANE.txt', data.text);
  console.log('PDF Extracted!');
}).catch(console.error);
