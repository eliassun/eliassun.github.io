import yaml
import os
import sys

network_interface = sys.argv[1] if len(sys.argv) > 1 else None

# Load the YAML configuration
with open('suricata_service_config.yaml', 'r') as file:
    config = yaml.safe_load(file)

# Determine which network interface to use
if network_interface:
    # If the network interface is passed as an argument, use it
    interface = network_interface
else:
    # Otherwise, use the interface from the config file
    interface = config['suricata']['interface']

# Read the systemd service template
with open('suricata.service.template', 'r') as template_file:
    service_template = template_file.read()

# Replace placeholders in the template
service_file_content = service_template.format(
    interface=interface,
    suricata_config=config['suricata']['suricata_config'],
    memory_limit=config['suricata']['memory_limit'],
    restart_delay=config['suricata']['restart_delay'],
    watchdog_timeout=config['suricata']['watchdog_timeout'],
    file_limit=config['suricata']['file_limit'],
    process_limit=config['suricata']['process_limit']
)

# Write the generated service file
with open('/etc/systemd/system/suricata.service', 'w') as output_file:
    output_file.write(service_file_content)

print("/etc/systemd/system/suricata.service generated successfully!")

