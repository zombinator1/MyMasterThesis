
function[s] = zmianaParametrowLotu(predkosc,FL,punktTrasy)
if predkosc <1000
   predkosc = "0" + predkosc;
end
if FL<100
    FL = "0"+FL;
end
    
    
s = punktTrasy+"/K"+predkosc+"F"+FL;
end