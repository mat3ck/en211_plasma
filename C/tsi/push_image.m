clear
close all
clc


image = imread('m31.ppm');
%image = imread('moon.pgm');

image = 0.6*image;

instrreset
s = serial('/dev/ttyUSB1');
s.Baudrate=115200;
s.StopBits=1;
s.Parity='none';
s.FlowControl='none';
s.TimeOut = 10;
s.OutputBufferSize = 1000000;
s.InputBufferSize = 5000000;
fopen(s);

for i = 1:63
    for(j = 1: 96)
        fwrite(s,image(i,j,1)); % R  
        fwrite(s,image(i,j,2)); % G
        fwrite(s,image(i,j,3)); % B
    end    
end
instrreset
%fclose(s);
