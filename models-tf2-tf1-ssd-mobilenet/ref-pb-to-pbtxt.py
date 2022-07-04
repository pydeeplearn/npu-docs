#!/usr/bin/env python
# ref-pb-to-pbtxt.py
#   convert pb to pbtxt for tf 2.xxx
#   https://stackoverflow.com/questions/57007707/failed-to-convert-tensorflow-frozen-graph-to-pbtxt-file


# use tensorflow 2.9.1


import tensorflow as tf
from google.protobuf import text_format
from tensorflow.python.platform import gfile

def graphdef_to_pbtxt(filename): 
    with open(filename,'rb') as f:
        graph_def = tf.compat.v1.GraphDef()
        graph_def.ParseFromString(f.read())
    with open('protobuf.txt', 'w') as fp:
        fp.write(str(graph_def))
    
##graphdef_to_pbtxt('saved_model.pb')
graphdef_to_pbtxt('frozen_inference_graph.pb')
##graphdef_to_pbtxt('tflite_graph.pb')

print("ok")

