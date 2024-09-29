
require 'socket'  # Require the socket library for network communication
require 'optparse'  # Require option parser for handling command-line arguments

# Note: This server only answers DNS queries for A records (IPv4). 
# Requests for other types of DNS records are ignored.

# Command-line argument parsing
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: dns_server.rb [options]"

  opts.on("-p PORT", "--port PORT", "Port for the DNS server (default: 53)") do |port|
    options[:port] = port.to_i
  end

  opts.on("-t TTL", "--ttl TTL", "Time-To-Live for DNS records in seconds (default: 60)") do |ttl|
    options[:ttl] = ttl.to_i
  end

  opts.on("-f FILENAME", "--file FILENAME", "File containing hostname=ip mappings") do |file|
    options[:hostname_ip_map_file] = file
  end
end.parse!

# Check if the hostname_ip_map file is provided
unless options[:hostname_ip_map_file]
  puts "Error: The hostname_ip_map file must be specified with the --file option."
  exit 1
end

# Function: SimpleDNSServer
# Description: A simple DNS server that handles A record queries.
# Parameters: hostname_ip_map - Hash mapping hostnames to IP addresses.
#             ttl - Time-to-live for DNS records (default: 300 seconds).
#             port - Port on which the server listens for DNS queries (default: 53).
class SimpleDNSServer
  def initialize(hostname_ip_map, ttl = 300, port = 53)
    @hostname_ip_map = hostname_ip_map
    @ttl = ttl
    @port = port
    @server = UDPSocket.new
    @server.bind('0.0.0.0', @port)
    puts "DNS Server running on port #{@port} with TTL #{@ttl}..."
  end

  # Function: start
  # Description: Starts the DNS server, awaiting and processing DNS queries.
  # Parameters: None
  # Returns: None
  def start
    loop do
      request, sender = @server.recvfrom(512)
      timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      puts "[#{timestamp}] Request from #{sender[2]}:#{sender[1]}"
      
      begin
        response = process_request(request, timestamp)
        @server.send(response, 0, sender[3], sender[1])
      rescue => e
        puts "Error processing request: #{e.message}"
      end
    end
  end

  # Function: process_request
  # Description: Processes a DNS request and generates a response.
  # Parameters: request - The received DNS request packet.
  #             timestamp - The time when the request was received.
  # Returns: response - The generated DNS response packet.
  def process_request(request, timestamp)
    id = request[0..1].b
    flags = "\x81\x80".b  # Standard response with no errors
    qdcount = "\x00\x01".b # Number of questions
    ancount = "\x00\x01".b # Number of answers
    nscount = "\x00\x00".b # Number of authority records
    arcount = "\x00\x00".b # Number of additional records

    hostname = extract_hostname(request)

    if @hostname_ip_map.key?(hostname)
      ip_address = @hostname_ip_map[hostname]
      puts "[#{timestamp}] Response Hostname: #{hostname}, IP: #{ip_address}"
      question = build_question(hostname)
      answer = build_answer(ip_address, @ttl)
      response = id + flags + qdcount + ancount + nscount + arcount + question + answer
    else
      puts "[#{timestamp}] Response Hostname: #{hostname} not found"
      response = id + "\x81\x83".b + qdcount + "\x00\x00".b + nscount + arcount + request[12..-1].b
    end

    return response
  end

  # Function: extract_hostname
  # Description: Extracts the hostname from the DNS request.
  # Parameters: request - The received DNS request packet.
  # Returns: hostname - The extracted hostname as a string.
  def extract_hostname(request)
    offset = 12
    labels = []
    while request[offset].ord > 0
      length = request[offset].ord
      labels << request[offset + 1, length].b
      offset += length + 1
    end
    return labels.join('.')
  end

  # Function: build_question
  # Description: Constructs the DNS question section of the response.
  # Parameters: hostname - The hostname to lookup.
  # Returns: question - The constructed question as a binary string.
  def build_question(hostname)
    labels = hostname.split('.').map { |label| [label.length].pack('C') + label }.join
    question = labels + "\x00".b
    question += "\x00\x01".b  # Type A (IPv4)
    question += "\x00\x01".b  # Class IN (Internet)
    return question.b
  end

  # Function: build_answer
  # Description: Constructs the DNS answer section containing the IP address.
  # Parameters: ip_address - The IP address corresponding to the hostname.
  #             ttl - Time-to-live for the DNS record.
  # Returns: answer - The constructed answer as a binary string.
  def build_answer(ip_address, ttl)
    answer = "\xC0\x0C".b  # Pointer to the question
    answer += "\x00\x01".b  # Type A (IPv4)
    answer += "\x00\x01".b  # Class IN (Internet)
    answer += [ttl].pack('N')  # TTL in Big Endian format
    answer += "\x00\x04".b  # Length of the answer (4 bytes for IPv4)
    answer += ip_address.split('.').map(&:to_i).pack('C*')  # Pack IP address into binary format
    return answer  # Return the constructed answer
  end
end

# Function: load_hostname_ip_map
# Description: Loads hostname to IP address mappings from the specified file.
# Parameters: file - The path to the hostname-to-IP mapping file.
# Returns: hostname_ip_map - Hash containing the mappings.
def load_hostname_ip_map(file)
  map = {}
  if File.exist?(file)
    File.readlines(file).each do |line|
      line.chomp!  # Remove newline character at the end
      key, value = line.split('=')
      map[key.strip] = value.strip if key && value  # Add to map if both key and value are present
    end
  else
    puts "Error: The specified file '#{file}' does not exist."
    exit 1
  end
  map
end

# Set defaults if no options provided
options[:port] ||= 53
options[:ttl] ||= 60
hostname_ip_map = {}

# Create and start the DNS server with provided options
hostname_ip_map = load_hostname_ip_map(options[:hostname_ip_map_file])
dns_server = SimpleDNSServer.new(hostname_ip_map, options[:ttl], options[:port])
dns_server.start
