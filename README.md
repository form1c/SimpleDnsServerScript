# Simple DNS Server in Ruby for Development Purposes

## Introduction

This simple Ruby DNS server script is designed for developers needing hostname resolution while working on network-related applications. It specifically supports A records (IPv4 addresses) and intentionally lacks complete DNS features, making it unsuitable for production use. This document outlines the components and functionalities of the server, along with instructions on how to run and utilize it effectively.

## How to Use

1. **Create a Hostname-IP Mapping File**: 
   The file should list hostnames and their corresponding IPs using the syntax `hostname=ip`. For example:
   ```
   example.com=192.168.1.1
   test.local=192.168.1.2
   ```
   Ensure the file is saved in a location that is accessible to your script.

2. **Run the Server**:
   Execute the server from the command line:
   ```bash
   ruby dns-server.rb --file path/to/your/hostname_ip_map.txt
   ```
   You can optionally specify the port and TTL if needed:
   ```bash
   ruby dns-server.rb --port 53 --ttl 60 --file path/to/your/hostname_ip_map.txt
   ```
   Make sure to run the command with sufficient permissions, especially if you are using a privileged port (like 53).

3. **Testing**:
   Use a DNS query tool like `nslookup` or `dig` to test your DNS server:
   ```bash
   nslookup example.com 127.0.0.1
   ```
   You should see the associated IP address returned as a response.

4. **Using UDP Server and Client for Testing**:
   To facilitate testing, you can use the provided UDP server and client scripts named `test/udp_server.rb` and `test/udp_client.rb`. These scripts can simulate client requests and facilitate communication with your DNS server.

   - **UDP Server**: It listens for messages on a specified port and can display received messages.
   - **UDP Client**: It sends messages to the UDP server and can be used to test the server's response to requests.

### Useful Windows DNS Commands

When working with the Windows command line, the following commands may be helpful for managing and troubleshooting DNS:

- **Display DNS Cache**:  
  Displays the contents of the DNS client resolver cache.
  ```bash
  ipconfig /displaydns
  ```

- **Flush DNS Cache**:  
  Clears the DNS resolver cache. This can be useful to ensure you're testing with the most recent DNS entries.
  ```bash
  ipconfig /flushdns
  ```

## Conclusion

The Simple Ruby DNS Server script serves as a tool for developers engaged in building network applications that rely on hostname resolution. While it is not suited for production environments, its design allows for quick testing of DNS-related functionalities in various projects. You are free to modify and extend this basic implementation to meet more complex requirements.