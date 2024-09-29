require 'socket'  # Require the socket library to use UDP sockets

# Function: send_message
# Description: Sends a message to a specified hostname and port using a UDP socket.
# Parameters:
#   - hostname: The address of the server to which the message is sent.
#   - port: The port number on which the server is listening.
#   - message: The message string to send to the server.
# Returns: None
def send_message(hostname, port, message)
  # Create a UDP socket
  udp_socket = UDPSocket.new  # Instantiate a new UDP socket

  # Send the message to the server
  udp_socket.send(message, 0, hostname, port)  # Send the message using the UDP socket

  puts "Message sent to #{hostname}:#{port} - Content: #{message}"  # Output a confirmation message to the console

  # Close the socket
  udp_socket.close  # Close the UDP socket to free up resources
end

# Function: send_messages_to_servers
# Description: Sends a "Hello World" message to multiple servers.
# Parameters:
#   - server_info: An array of hashes containing server details (hostname and port).
# Returns: None
def send_messages_to_servers(server_info)
  # Iterate over the provided servers
  server_info.each do |server|
    hostname = server[:hostname]  # Get the hostname from the hash
    port = server[:port]  # Get the port from the hash
    timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")  # Get the current time and format it
    message = "Hello World to #{hostname} on port #{port} at #{timestamp}!"  # Construct the message

    begin
      send_message(hostname, port, message)  # Call the function to send the message
    rescue SocketError => e
      puts "Failed to resolve hostname #{hostname}: #{e.message}"  # Output an error message on hostname resolution failure
    rescue StandardError => e
      puts "An error occurred while sending message to #{hostname}:#{port} - Error: #{e.message}"  # Handle any other errors
    end
  end
end

# Define server information with hostnames and ports
servers = [
  { hostname: 'myserver1.de', port: 12345 },
  { hostname: 'myserver2.de', port: 12345 },
  { hostname: 'myserver3.de', port: 12345 },
  { hostname: 'myserver4.de', port: 12345 }
]

# Call the function to send messages
send_messages_to_servers(servers)