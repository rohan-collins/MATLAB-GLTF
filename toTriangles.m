function F=toTriangles(F)
% Converts polygons to triangles, so that each polygon is converted
% to a triangle fan with an identifying vertex that is different
% from the previous polygon's.
    F=reshape(F(:,reshape([ones(1,size(F,2)-2);2:size(F,2)-1;3:size(F,2)],3*(size(F,2)-2),1)')',3,[])';
    F=F(~any(isnan(F),2),:);        
end
