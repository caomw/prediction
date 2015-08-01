function out = wavelet_transf_batch(in, J, train, Hm)
%this function computes a wavelet transform along each row of in

if nargin < 3
	train=0;
end
if J==0
out = gpuArray(single(in));
return
end

[~,C, N, BS]=size(in);

if train==1
res = squeeze(in);
res = res(:,:);
res = Hm * res;
res = reshape(res, size(Hm,1), N, BS);
res = permute(res, [2 1 3]);
res = reshape(res, size(Hm,1)*N, BS);
out = zeros(1, 1, size(res,1), size(res,2), 'single','gpuArray');
out(1,1,:,:) = res;
return;

end


Ceff = C - 2^J;
out = zeros(1,Ceff,N* BS,J+1,'single','gpuArray');

res = squeeze(in);
res = res(:,:);
p=round(2^J/2);

for j=1:J
haar=ones(2^j,1);
haar=gpuArray(single(haar));
haar(1:2^(j-1))=1/sqrt(2^j);
haar(2^(j-1)+1:end)=-1/sqrt(2^j);

tmp = conv2(res,haar,'same');
out(1,:,:,j) = tmp(p+1:end-p,:);

if j==J
haar(2^(j-1)+1:end)=+1/sqrt(2^j);
tmp = conv2(res,haar,'same');
out(1,:,:,J+1) = tmp(p+1:end-p,:);
end

end

out = reshape(out, 1, Ceff, N, BS, J+1);
out = permute(out, [1 2 3 5 4]);
out = reshape(out, 1, Ceff, N*(J+1), BS);
out(1,:,1:N,:) = in(1,p+1:end-p,:,:);

%if train==1
%out = out(1,ceil(size(out,2)/2),:,:);
%end

end


