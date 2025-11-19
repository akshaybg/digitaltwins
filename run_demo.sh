#!/bin/bash
# Simple demo launcher - No Docker needed!

echo "🏗️  Construction Site Digital Twin - Demo Mode"
echo "=============================================="
echo ""

# Use existing AWS environment if available, otherwise create new one
if [ -f "$HOME/aws_env/bin/activate" ]; then
    echo "🔧 Using existing aws_env environment..."
    source ~/aws_env/bin/activate
else
    echo "📦 Setting up Python environment..."
    # Check if we need to install python3-venv
    if ! python3 -m venv --help &> /dev/null; then
        echo "⚠️  python3-venv not found. Installing..."
        echo "Please run: sudo apt install python3-venv python3-full"
        exit 1
    fi

    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    source venv/bin/activate
fi

# Install dependencies
echo "📥 Installing dependencies..."
pip install -q --upgrade pip
pip install -q -r requirements.txt

echo ""
echo "✅ Setup complete!"
echo ""
echo "🚀 Starting Construction Site Digital Twin..."
echo ""
echo "📍 Access point:"
echo "   🎮 3D Visualization: http://localhost:8001/"
echo ""
echo "Press Ctrl+C to stop the demo"
echo ""
echo "================================================"
echo ""

# Run the application
python3 construction_digital_twin.py
