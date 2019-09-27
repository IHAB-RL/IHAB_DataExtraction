% struct to containers.Map

load('IdentificationProbandSystem.mat');

mapSubject_1 = containers.Map({stSubject_1.ID}, {stSubject_1.System});
mapSubject_2 = containers.Map({stSubject_2.ID}, {stSubject_2.System});
mapSystem = containers.Map({stSystem.System}, {stSystem.Calib});

save('IdentificationProbandSystem_Maps.mat', ...
    'mapSubject_1', 'mapSubject_2', 'mapSystem');