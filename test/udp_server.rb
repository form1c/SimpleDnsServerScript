require 'socket'  # Require the socket library to utilize UDP sockets

# Define the port on which the server will listen
PORT = 12345  # Replace this with the desired port

# Function: setup_udp_server
# Description: Creates and binds a UDP socket to a specified port, ready to receive messages.
# Parameters:
#   - port: The port number on which the server will listen for incoming messages.
# Returns:
#   - udp_socket: The configured UDP socket ready to receive messages.
def setup_udp_server(port)
  udp_socket = UDPSocket.new  # Instantiate a new UDP socket
  udp_socket.bind('0.0.0.0', port)  # Bind the socket to listen on all interfaces
  udp_socket  # Return the configured UDP socket
end

# Function: run_server
# Description: Main loop that continuously receives and handles incoming UDP messages.
# Parameters:
#   - port: The port number on which the server is listening.
#   - udp_socket: The UDP socket used for receiving messages.
# Returns: None
def run_server(port, udp_socket)
  puts "UDP server is running and waiting for messages on port #{port}..."  # Inform that the server is ready
  loop do
    message, sender = udp_socket.recvfrom(1024)  # Receive a message; 1024 is the maximum size
    output_received_message(message, sender)  # Handle the received message
  end
end

# Function: output_received_message
# Description: Outputs the received message along with the sender's address to the console.
# Parameters:
#   - message: The content of the received message as a string.
#   - sender: An array containing sender information (IP, port, etc.).
# Returns: None
def output_received_message(message, sender)
  puts "Message received from #{sender[2]}:#{sender[1]} - Content: #{message}"  # Print sender's IP and port along with message content
end

# Start the server by setting up the UDP socket and entering the main server loop
udp_socket = setup_udp_server(PORT)  # Setup the UDP server
run_server(PORT, udp_socket)  # Begin the main server loop
