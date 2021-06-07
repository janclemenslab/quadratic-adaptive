function varargout = myPlotMult(X,Y, varargin)


labels = {};
if nargin==1
   Y = X; 
   X = [];
end

if nargin>2
   labels = varargin{1}; 
end

marks = '.+oxsdv<>ph';
cols = 'kbgrcmy';
if isempty(X)
    X = 1:size(Y,2);
end
X = X(:);

for x=1:size(Y,1)
    if length(size(Y))==2
        tmp = Y(x,:);
        subplot(size(Y,1),1 ,x)
        hold on;
        %        plot(X,tmp(:),cols(mod(x,length(cols))+1 ));
        h(x) = plot(X,tmp(:),'k','LineWidth',1.5);
        axis('tight');
        %grid on;
        %        set(gca,'xtick', );
        %        set(gca,'xticklabel',[] );
        if not(isempty(labels))
            ylabel(labels{x});
        end
        set(gca,'YLim',[min(Y(:)), max(Y(:))]);
    elseif length(size(Y))==3
        for z=1:size(Y,2)
            tmp = Y(x,z,:);
            subplot(size(Y,1),size(Y,2) ,(x-1)*size(Y,1) + z)
            %            plot(X,tmp(:),cols(mod(x,length(cols))+1 ));
            h(x) = area(X,tmp(:));
            axis('tight');
        end
    end
    if x<size(Y,1)
        set(gca,'XTickLabel',[]);
    end
end
if nargout>0
   varargout{1} = h;
end


