function db = convert2double(img)

img = double(img);
db = img./max(img(:));

end