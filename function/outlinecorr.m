function STEC_rm_ol= outlinecorr(STEC)
% Remove Outlinier of STEC

STECo = STEC';
STEC_m = nanmedian(STECo,1)';

% set bound
bound = 10; % TECu 5 for high/mid lattitude 10 for low lattitude region
for pp = 1:length(STEC(1,:))
    [val,~] = find(~isnan(STEC(:,pp)));
    z = find(diff(val)>=3600); % 1hr
        if isempty(z) 
            if abs(nanmean(STEC(:,pp)-STEC_m))>bound
                STEC(:,pp)=nan;
            end
            continue
        end
    z(length(z)+1) = length(val);
    for y = 1:length(z)
        if y == 1
            countdif = abs(STEC(val(1):val(z(y)),pp)-STEC_m(val(1):val(z(y))))>bound;
            r_length = sum(~isnan(STEC_m(val(1):val(z(y)))));
            if sum(countdif(:) == 1) > r_length/2
                STEC(val(1):val(z(y)),pp)=nan;
            end
            clear countdif r_length
        else
            countdif = abs(STEC(val(z(y-1)+1):val(z(y)),pp)-STEC_m(val(z(y-1)+1):val(z(y))))>bound;
            r_length = sum(~isnan(STEC_m(val(z(y-1)+1):val(z(y)))));
            if sum(countdif(:) == 1) > r_length/2
                STEC(val(z(y-1)+1):val(z(y)),pp)=nan;
            end
            clear countdif r_length
        end
    end
end

STEC_rm_ol = STEC;
end
