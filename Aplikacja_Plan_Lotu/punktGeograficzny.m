function[s]=punktGeograficzny(lat,lon)
stopnieSzerGeogr=floor(lat);
minutySzerGeogr =round((lat - floor(lat))*60);
if minutySzerGeogr >59
    minutySzerGeogr="00";
stopnieSzerGeogr=stopnieSzerGeogr+1;
else
if minutySzerGeogr < 10
   minutySzerGeogr = "0" + minutySzerGeogr; 
end
end
stopnieDlugGeogr=floor(lon);
minutyDlugGeogr =round((lon - floor(lon))*60);
if minutyDlugGeogr >59
    minutyDlugGeogr="00";
stopnieSzerGeogr=stopnieSzerGeogr+1;
else
if minutyDlugGeogr < 10
   minutyDlugGeogr = "0" + minutyDlugGeogr; 
end
end

if lat>=0
    NS = "N";
else
    NS = "S";
end

if lat>=0
    WE = "E";
else
    WE = "W";
end

s = string(stopnieSzerGeogr)+string(minutySzerGeogr) + NS + "0"+string(stopnieDlugGeogr)+string(minutyDlugGeogr)+WE;
end