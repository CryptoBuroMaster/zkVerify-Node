#!/bin/bash

# Update system
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# Install Git
echo "Installing Git..."
sudo apt install git -y
git --version

# Install Python 3.11
echo "Installing Python 3.11..."
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install python3.11 python3.11-venv python3.11-dev -y
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
python3 --version

# Install pip
echo "Installing Python pip..."
sudo apt install python3-pip -y
python3 -m pip install --upgrade pip setuptools wheel

# Install build dependencies
echo "Installing build-essential..."
sudo apt install build-essential -y

# Install virtualenv
echo "Installing virtualenv..."
pip install virtualenv

# Install Poetry
echo "Installing Poetry..."
curl -sSL https://install.python-poetry.org | python3 -
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
poetry --version

# Install Node.js and npm
echo "Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
node -v
npm -v

# Clone Vana DLP repository
echo "Cloning the Vana DLP repository..."
git clone https://github.com/vana-com/vana-dlp-chatgpt.git
cd vana-dlp-chatgpt

# Create .env file
echo "Creating .env file..."
cp .env.example .env

# Install dependencies using Poetry
echo "Installing dependencies..."
poetry install

# Set up virtual environment and install vana CLI
echo "Setting up virtual environment..."
virtualenv venv
source venv/bin/activate
pip install vana


# File to save wallet data
DATA_FILE="private.json"

# Create wallet
echo "Creating wallet..."
vanacli wallet create --wallet.name default --wallet.hotkey default

# Function to export private keys without user interaction
export_private_key() {
  local key_type=$1
  local key=$(vanacli wallet export_private_key --wallet.name default --keytype "$key_type" 2>&1)
  
  if [[ $key == *"Error"* ]]; then
    echo "Failed to export $key_type private key: $key"
    exit 1
  fi

  echo "$key"
}

# Export private keys for coldkey and hotkey
echo "Exporting Coldkey private key..."
coldkey_private=$(export_private_key coldkey)

echo "Exporting Hotkey private key..."
hotkey_private=$(export_private_key hotkey)

# Save private keys to private.json
echo "Saving private keys to private.json..."
json_data=$(cat <<EOF
{
  "coldkey_private": "$coldkey_private",
  "hotkey_private": "$hotkey_private"
}
EOF
)


# Save data to private.json
echo "$json_data" > "$DATA_FILE"
print_info "Wallet data saved to $DATA_FILE."

# Generate Encryption Keys
echo "Generating Encryption Keys..."
chmod +x keygen.sh
./keygen.sh

# Move generated encryption keys files to the current folder
echo "Moving generated encryption key files to current folder..."
mv public_key.asc public_key_base64.asc private_key.asc private_key_base64.asc .

# Display output for private keys and generated files
echo "Process completed!"
echo "Coldkey and Hotkey private keys saved in private.json."
echo "Encryption keys saved in the current folder: public_key.asc, public_key_base64.asc, private_key.asc, private_key_base64.asc."
