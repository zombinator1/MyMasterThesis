function[Z_mniejsze]=elewacja2500(Z)

rubryki_do_zachowania=[];


for i=2:24:length(Z)
  rubryki_do_zachowania=[rubryki_do_zachowania i];
end
Z_mniejsze = Z(rubryki_do_zachowania,rubryki_do_zachowania);
Z_mniejsze=Z_mniejsze(:);
Z_mniejsze=double(Z_mniejsze);

% Define grid of target locations in region of interest

end