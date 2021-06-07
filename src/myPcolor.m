function varargout = myPcolor(x,y,matrix)
%disp ...

%ARGS:
% x
% y
% matrix - x*y Matrix
%RETURNS:
% void

% last modified 13/04/09 JC - changed from pcolor to imagesc, might have
% messed up the YTickLabels...

if nargin==1
    matrix = x;
    x = [];
    y = [];
end
matrix = double(matrix);
if isempty(x)
    x = 1:size(matrix,2);
end
if isempty(y)
    y = 1:size(matrix,1);
end

% matrix1 = flipud(matrix);
% ax = imagesc(x, y, matrix);
% axis('xy');
% %set(ax,'alphadata',~isnan(matrix));

% YTick = get(gca,'YTick');
% YTickLabel = get(gca,'YTickLabel');
% set(gca,'YTick',fliplr(max(y)+1.5-YTick),...
%     'YTickLabel',flipud(YTickLabel))

matrix = [matrix matrix(:,end); [matrix(end,:) matrix(end,end)]];
ax = pcolor(matrix);
shading flat;% for non-blurry pdfs
set(ax, 'EdgeColor','none');
set(gca,'XTick',(1:size(matrix,2)) +.5,'XTickLabel',[x []])
set(gca,'YTick',(1:size(matrix,1)) +.5,'YTickLabel',[y []])

if nargout>0
    varargout{1} = ax;
end

%%
    
