function paths = paths2matlab(filename)

fileID = fopen(filename,'r');
paths = cell([1,1]);

n = 0;
tline = fgetl(fileID);

while ischar(tline)
    
  x = split(tline);
  
  size_x = size(x); 
  len = size_x(1);
  
  
  path_arr = [];
 
  for i = 1:len
      path_arr = [path_arr, str2num(x{i})];
  end 
  
  n = n+1;
  paths{n,1} = path_arr;
  
  tline = fgetl(fileID);
end

fclose('all');

end