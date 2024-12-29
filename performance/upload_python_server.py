from http.server import BaseHTTPRequestHandler, HTTPServer
import os
import cgi

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    upload_dir = "uploads"  # Directory to save uploaded files

    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(b"<html><body>")
        self.wfile.write(b"<h1>Upload a File</h1>")
        self.wfile.write(b"""
        <form enctype="multipart/form-data" method="post">
            <input name="file" type="file"/>
            <input type="submit" value="Upload"/>
        </form>
        """)
        self.wfile.write(b"</body></html>")

    def do_POST(self):
        print("POST request received")
        content_type = self.headers.get("Content-Type")
        print(f"Content-Type: {content_type}")
        if not content_type.startswith("multipart/form-data"):
            print("Unsupported Content-Type")
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b"Unsupported Content-Type")
            return

        print("Processing multipart/form-data")
        try:
            _, params = cgi.parse_header(content_type)
            boundary = params["boundary"].encode("utf-8")
            content_length = int(self.headers["Content-Length"])
            form_data = self.rfile.read(content_length)
            print(f"Form data received: {len(form_data)} bytes")

            # Split parts based on the boundary
            parts = form_data.split(b"--" + boundary)

            for part in parts:
                if not part or part == b"--\r\n":
                    continue  # Skip empty parts or the final boundary marker

                if b"Content-Disposition" in part:
                    headers, file_data = part.split(b"\r\n\r\n", 1)
                    file_data = file_data.rstrip(b"\r\n--")
                    disposition = headers.decode().split("\r\n")[0]

                    # Extract filename from the Content-Disposition header
                    if "filename" in disposition:
                        filename = cgi.parse_header(disposition.split(";")[2])[1]["filename"]
                        print(f"Processing file: {filename}")

                        # Save the file to the upload directory
                        if not os.path.exists(self.upload_dir):
                            os.makedirs(self.upload_dir)
                        file_path = os.path.join(self.upload_dir, filename)
                        with open(file_path, "wb") as f:
                            f.write(file_data)

                        self.send_response(200)
                        self.end_headers()
                        self.wfile.write(f"File uploaded successfully: {filename}".encode())
                        print(f"File uploaded successfully: {file_path}")
                        return

            print("No valid file found in the form data")
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b"No valid file uploaded.")
        except Exception as e:
            print(f"Error during file upload: {e}")
            self.send_response(500)
            self.end_headers()
            self.wfile.write(b"Internal Server Error")


def run(server_class=HTTPServer, handler_class=SimpleHTTPRequestHandler, port=8000):
    server_address = ("", port)
    httpd = server_class(server_address, handler_class)
    print(f"Starting server on port {port}...")
    httpd.serve_forever()

if __name__ == "__main__":
    run()
