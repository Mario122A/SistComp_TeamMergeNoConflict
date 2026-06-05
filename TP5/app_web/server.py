from flask import Flask, render_template, jsonify
import time
import os

app = Flask(__name__)

DEVICE_PATH = "/dev/TeamMergeNoConflict"
current_signal_id = 1

# Guardamos el momento en que inicia el servidor para que el tiempo empiece en 0
start_time = time.time()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/read_signal')
def read_signal():
    scaled_value = 0.0
    try:
        # CORRECCIÓN VITAL: 'rb' y buffering=0 para evitar el Kernel Panic en QEMU
        with open(DEVICE_PATH, 'rb', buffering=0) as dev:
            char_read = dev.read(1)
            
            # Al leer en binario, comparamos con bytes (b'1')
            if char_read == b'1':
                scaled_value = 3.3
            else:
                scaled_value = 0.0
                
    except Exception as e:
        print(f"Error CDD: {e}")
        scaled_value = 0.0

    # Calculamos los segundos exactos desde que empezó a medir (ej: 0.00, 1.25, 2.50)
    elapsed_time = time.time() - start_time

    return jsonify({
        "timestamp": f"{elapsed_time:.2f}",
        "value": scaled_value,
        "signal_id": current_signal_id
    })

@app.route('/api/set_signal/<int:sig_id>', methods=['POST'])
def set_signal(sig_id):
    global current_signal_id
    global start_time
    try:
        with open(DEVICE_PATH, 'w') as dev:
            dev.write(str(sig_id))
        
        current_signal_id = sig_id
        
        # Resetea el cronómetro a 0 exactamente cuando cambiás de señal
        start_time = time.time() 
        
        return jsonify({"status": "success"})
    except Exception as e:
        print(f"Error CDD: {e}")
        return jsonify({"status": "error"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=False)