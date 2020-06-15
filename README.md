# docker-alpine-corretto

Docker with Alpine Linux and AWS Corretto 11

## How to create RootCA

Please refer https://gist.github.com/fntlnz/cf14feb5a46b2eda428e000157447309

* **Step 1:** Create Root Key

openssl genrsa -out mcp-root.key 4096

* **Step 2:** Create and self sign the Root Certificate (Valid for 15 years)

openssl req -x509 -new -nodes -key mcp-root.key -subj "/C=SG/ST=Singapore/L=Singapore/O=Mobile Credit Payment Pte Ltd/OU=DevOps/CN=MCP Root CA" -sha256 -days 5475 -out mcp-root-ca.crt