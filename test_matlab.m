mov = VideoReader("/home/martin/Desktop/forEmi/2021_07_26_B.avi");
prev_frame_time = 0
curr_frame_time = 0

figure
h = imagesc(zeros(mov.Height,mov.Width,3));

tic
while mov.hasFrame
    img = mov.readFrame();
    new_frame_time = toc;
    fps = 1/(new_frame_time-prev_frame_time);
    prev_frame_time = new_frame_time;
    img = insertText(img, ...
        [7 70], ...
        num2str(round(fps)),...
        'FontSize',70,...
        'TextColor',[100 255 0],...
        'BoxOpacity',0);
    h.CData = img;
    drawnow
end