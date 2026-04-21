
import sounddevice as sd
import numpy as np

def detect_scream(audio):
    volume = np.linalg.norm(audio)
    if volume > 10:
        print("Possible scream detected")
