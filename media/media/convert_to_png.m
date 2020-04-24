imList = dir('*.tif');
mkdir('out_png')

for i = 1:length(imList)
    currImAllName = imList(i).name;
    [~, currImName, ~] = fileparts(currImAllName);
    
    im = imread(currImAllName);
    imwrite(im, fullfile('out_png', [currImName '.png']));
end