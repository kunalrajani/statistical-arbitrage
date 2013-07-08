function pred_mat = pca_reg_pred(input_mat,var_reqd,horizon)

% standardize and find the covariance matrix
[std_input_mat mu sigma]= zscore(input_mat');
covar_ind = cov(std_input_mat);

%conduct eigen value decomposition
[V D] = eig(covar_ind);
eval = sum(D,1);
eval = wrev(eval);

%find the eigen vectors that explain specified variance
explain_var = find(cumsum(eval)/sum(eval)>=var_reqd);
num_vectors = explain_var(1);
vectors = V(:,end-num_vectors+1:end);

%create the scores using those eigenvectors. The last col is the most
%explainatory
pca_comp = std_input_mat*vectors;

% First forecast each of the 22 pca components using Garch
spec = garchset('R',1,'M',1,'P',1,'Q',1);   %Note that Display off doesn't reflect in Errors

% est_pca_comp = repmat(mean(pca_comp,1),horizon,1);
est_pca_comp = zeros(horizon,size(pca_comp,2));
for l=1:num_vectors
    [Coeff,Errors,LLF,Innovations,Sigmas,Summary] = garchfit(spec,double(pca_comp(:,l)));
    if(Summary.exitFlag>0)
        [est_sigma,est_mean] = garchpred([Coeff,Errors],double(pca_comp(:,l)),horizon);
    else
        est_mean = repmat(mean(pca_comp(:,l)),horizon,1);
    end
    est_pca_comp(:,l) = est_mean;
end

% Now regress the past values on the past values of the pca comps
lin_coeff = zeros(num_vectors+1,size(std_input_mat,2));
X = [pca_comp ones(size(pca_comp,1),1)];
R_sq = 0;
for l=1:size(std_input_mat,2)
    y = std_input_mat(:,l);
    [b,bint,r,rint,stats] = regress(y,X);
    lin_coeff(:,l) = b';
    R_sq = R_sq + stats(1);
end

% Now predict the future values of the input matrix
est_pca = [est_pca_comp ones(horizon,1)];
pred_mat = est_pca*lin_coeff;
pred_mat = pred_mat.*repmat(sigma,horizon,1) + repmat(mu,horizon,1);
pred_mat = pred_mat';
