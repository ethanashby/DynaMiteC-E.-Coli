function plot_impluse(p, x, y, label, style, data, lw, marks)

if nargin<4, label=0; end
if nargin<5, style='--r'; end
if nargin<6, data=0; end
if nargin<7, lw=2; end
if nargin<8, marks=1; end

hold on;
if data
    plot(x, y, style, 'LineWidth', lw);
%     plot(x,y,'s', 'MarkerFaceColor', 'g', 'MarkerEdgeColor','k','MarkerSize',5);
else
    plot(0:max(x), impulse(p,0:max(x)), style, 'LineWidth', lw);
end

if marks
    plot(p(4),impulse(p,p(4)),'^', p(5),impulse(p,p(5)),'v', 'MarkerFaceColor', 'y', 'MarkerEdgeColor','k','MarkerSize',5);
end

end

