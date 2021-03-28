
function [best_fit_parm, LL, BIC] = RLpar_model(alpha,beta,Nfit,ndesiredworkers)

p = gcp('nocreate');
if ~isempty(p)
    Nwork = p.NumWorkers;
else
    Nwork = 0;
end
if Nwork ~= ndesiredworkers
  delete(gcp('nocreate'))
  parpool('local', ndesiredworkers, 'IdleTimeout', 30);
end

% R=1, G=3, B=5
color_value = [1,5,9];
nrep = 30;
    
% color-position mapping: Left,middle,Right
ord = perms(1:3); % 6 permutations
stim = repmat(ord,nrep,1); % 1=red, 2=green, 3=blue
ntrl = size(stim,1);

% value:
tmp = color_value(ord);
tmp = repmat(tmp,nrep,1); 

% reward probability = 50%
tmp(1:ntrl/2, 1) = 0;
tmp(ntrl/2+1:end, 3) = 0;
value = tmp;

% middle option unavailable:
value(:,2) = NaN;
    
% for convenience, let's put red in the 1st col, green 2nd, blue 3rd:
stim_val = []; % R, G, B, 3 colors
for color = 1:3
    for trl = 1:size(stim,1)
        stim_val(trl,color) = value(trl,stim(trl,:)==color);
    end
end
% so, in stim_val: red is the 1st col, green 2nd, blue 3rd;

% shuffle trial order:
shuffle_trl = randperm(ntrl);
stim_val    = stim_val(shuffle_trl,:);
stim        = stim(shuffle_trl,:);

% initialize/pre-allocate variables:
Q           = zeros(3,1); % expected value (vector)
location    = nan(ntrl,1); % true choices
sim_choice  = nan(ntrl,1);
outcome     = nan(ntrl,1);
dis         = nan(ntrl,1);
for trl = 1:ntrl
    % Model: Rescorla-Wagner RL
    reward          = stim_val(trl,:)'; % ordered by color
    dis(trl,1)      = find(isnan(reward)); % distractor (which color is dis)
    [Q, ch]         = simulate_RescorlaWagner(alpha,beta,reward,Q);
    sim_choice(trl) = ch; % which color is chosen
    outcome(trl)    = stim_val(trl,ch); % reward obtained on this trial given 'ch'
    location(trl,1) = find(stim(trl,:)==ch); % the location 'ch' corresponds to
end % end of trial
    

disp('>>>>>>> ok, we have simulated some data >>>>>>>')
disp('>>>>>>> ok, we have simulated some data >>>>>>>')
disp('>>>>>>> ok, we have simulated some data >>>>>>>')


tic
[best_fit_parm, LL, BIC] = fit_RL(sim_choice, outcome, dis, Nfit);
toc

fprintf('true alpha = %3f, estimated alpha = %3f\n',alpha, best_fit_parm(1))
fprintf('true beta = %3f, estimated beta = %3f\n',beta, best_fit_parm(2))

delete(gcp('nocreate'))

end



function [Q,choice] = simulate_RescorlaWagner(alpha,beta,reward,Q)

    AB = find(~isnan(reward)); % which two colors are available to choose
    Vx = Q(AB); % value of the 2 options
    pp = exp(beta.*Vx)./sum(exp(beta.*Vx)); % softmax probabilities
    choice = AB(sim_choose(pp)); % simulated choice
    updt = zeros(3,1);
    updt(choice) = 1;
    r = reward;
    r(isnan(r)) = 0; % set distractor (unchoosenable) value to 0
    % update the expected value Q:
    Q = Q + updt.*alpha.*(r-Q);
end


function a = sim_choose(p)
    % simulate choise based on probabilities
    if size(p,1)>1
        p = p';
    end
    a = max(find([-eps cumsum(p)] < rand));

end



function [Xfit, LL, BIC] = fit_RL(a, r, d, Nfit)
    % yinan cao, 12/2020
    obFunc = @(x) LL_RescorlaWagner(a, r, d, x(1), x(2));
    LB = [0 0];
    UB = [1 inf];
    for iter = 1:Nfit
        X0(iter,:) = [rand exprnd(1)];
    end
    feval = [50000, 50000]; % max number of function evaluations and iterations
    options = optimset('MaxFunEvals',feval(1),'MaxIter',feval(2),'Display','off');

    parfor iter = 1:Nfit
        [Xfit_grid(iter,:), NegLL_grid(iter)] = fmincon(obFunc, X0(iter,:), [], [], [], [], LB, UB, [], options);
    end

    [~,best] = min(NegLL_grid);
    Xfit = Xfit_grid(best,:);
    NegLL = NegLL_grid(best);

    LL = -NegLL;
    BIC = length(X0(1,:)) * log(length(a)) + 2*NegLL;
end



function [NegLL,pred_p,Qs] = LL_RescorlaWagner(a, r, distractor, alpha, beta)
    Q = zeros(3,1);
    ntrl = length(a);
    Qs = [];
    for t = 1:ntrl
        d = distractor(t);
        ab = setdiff(1:3,d);
        v = beta*Q(ab);
        p = exp(v-max(v)) / sum(exp(v-max(v))); % predicted p for ab

        pp = nan(3,1); % clear
        pp(ab) = p;
        pred_p(t,:) = pp;
        % compute choice probability for actual choice
        choiceProb(t) = pp(a(t));
        % update values
        delta = r(t) - Q(a(t));
        Q(a(t)) = Q(a(t)) + alpha * delta;
        Qs = [Qs,Q];
    end
    % compute negative log-likelihood
    NegLL = -sum(log(choiceProb));
end

