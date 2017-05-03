function ret = weight_surface_one (r,theta,a,k,b,l,os,wg)
% os is an offset - the location of a peak of the cosine. wg is a
% "gain on the width of the cosine".
    
    ret = [];
    sz = size(a)(2);
    for i = 1:sz
        one = (a(i) .* exp(k(i).*r) .- b(i) .* exp(l(i).*r)) ...
              .* cos (2.*pi .* (wg(i).*(theta-os(i))./50));
        ret(:,:,i) = one;
    end
end
