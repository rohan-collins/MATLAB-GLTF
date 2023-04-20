% Download "A Beautiful Game" chess set.
[chess,piece_node]=ABeautifulGame();
% Encode the moves of "The Game of the Century".
game=[
    "G1" "f3" missing missing;
    "G8" "f6" missing missing;
    "C2" "c4" missing missing;
    "G7" "g6" missing missing;
    "B1" "c3" missing missing;
    "F8" "g7" missing missing;
    "D2" "d4" missing missing;
    "E8" "g8" "H8" "f8";
    "C1" "f4" missing missing;
    "D7" "d5" missing missing;
    "D1" "b3" missing missing;
    "D7" "c4" "C2" "z8";
    "D1" "c4" "D7" "i1";
    "C7" "c6" missing missing;
    "E2" "e4" missing missing;
    "B8" "d7" missing missing;
    "A1" "d1" missing missing;
    "B8" "b6" missing missing;
    "D1" "c5" missing missing;
    "C8" "g4" missing missing;
    "C1" "g5" missing missing;
    "B8" "a4" missing missing;
    "D1" "a3" missing missing;
    "B8" "c3" "B1" "z7";
    "B2" "c3" "B8" "i2";
    "G8" "e4" "E2" "z6";
    "C1" "e7" "E7" "i3";
    "D8" "b6" missing missing;
    "F1" "c4" missing missing;
    "G8" "c3" "B2" "z5";
    "C1" "c5" missing missing;
    "H8" "e8" missing missing;
    "E1" "f1" missing missing;
    "C8" "e6" missing missing;
    "C1" "b6" "D8" "i4";
    "C8" "c4" "F1" "y8";
    "E1" "g1" missing missing;
    "G8" "e2" missing missing;
    "E1" "f1" missing missing;
    "G8" "d4" "D2" "y7";
    "E1" "g1" missing missing;
    "G8" "e2" missing missing;
    "E1" "f1" missing missing;
    "G8" "c3" missing missing;
    "E1" "g1" missing missing;
    "A7" "b6" "C1" "y6";
    "D1" "b4" missing missing;
    "A8" "a4" missing missing;
    "D1" "b6" "A7" "j1";
    "G8" "d1" "A1" "y5";
    "H2" "h3" missing missing;
    "A8" "a2" "A2" "x8";
    "E1" "h2" missing missing;
    "G8" "f2" "F2" "x7";
    "H1" "e1" missing missing;
    "H8" "e1" "H1" "x6";
    "D1" "d8" missing missing;
    "F8" "f8" missing missing;
    "G1" "e1" "H8" "j2";
    "C8" "d5" missing missing;
    "G1" "f3" missing missing;
    "G8" "e4" missing missing;
    "D1" "b8" missing missing;
    "B7" "b5" missing missing;
    "H2" "h4" missing missing;
    "H7" "h5" missing missing;
    "G1" "e5" missing missing;
    "E8" "g7" missing missing;
    "E1" "g1" missing missing;
    "F8" "c5" missing missing;
    "E1" "f1" missing missing;
    "G8" "g3" missing missing;
    "E1" "e1" missing missing;
    "F8" "b4" missing missing;
    "E1" "d1" missing missing;
    "C8" "b3" missing missing;
    "E1" "c1" missing missing;
    "G8" "e2" missing missing;
    "E1" "b1" missing missing;
    "G8" "c3" missing missing;
    "E1" "c1" missing missing;
    "A8" "c2" missing missing;
    ];

% Generate times
seconds=sum(~ismissing(game(:,1:2:end)),2);
% Correct times for castling moves.
castles=[
    "E1"    "g1"    "H1"    "f1";
    "H1"    "f1"    "E1"    "g1";
    "E8"    "g8"    "H8"    "f8";
    "H8"    "f8"    "E8"    "g8";
    ];
seconds=seconds-ismember(game(:,1:4),castles,'rows');

% Generate start and end times for each move.
tstart=nan(size(game,1),size(game,2)/2);
tend=nan(size(game,1),size(game,2)/2);
tstart(:,1)=[0;cumsum(seconds(1:end-1)+1)]+1;
tend(:,1)=tstart(:,1)+1;
tstart(~ismissing(game(:,3)),2)=tend(~ismissing(game(:,3)),1);
tstart(ismember(game(:,1:4),castles,'rows'),2)=tstart(ismember(game(:,1:4),castles,'rows'),1);
tend(~ismissing(game(:,3)),2)=tstart(~ismissing(game(:,3)),2)+1;
for i=5:2:size(game,2)
    tstart(~ismissing(game(:,i)),(i+1)/2)=tend(:,(i-1)/2);
    tend(~ismissing(game(:,i)),(i+1)/2)=tstart(~ismissing(game(:,i)),(i+1)/2)+1;
end

% Uncomment to only save last 12 seconds of game.
% start_T=max(tend,[],'all')-12;
% Wait 3 seconds after game ends for resignation animation.
maxt=max(tend,[],'all')+3;
% Pieces and positions names
pieces=upper(string(num2cell(char(97:104)))+string([1 2 7 8]'));
positions=string(num2cell(char([120:122 97:106])))+string(1:8)';

% Positions including off-the-board ones for taken pieces.
[X,Z]=meshgrid([-8.5:-6.5 -3.5:3.5 6.5:7.5],3.5:-1:-3.5);
X=X/16;
Z=Z/16;
% Off-the-board positions should be on the table level.
temp=chess.getAccessor(chess.meshes{1}.primitives{1}.attributes.POSITION);
Y=zeros(size(positions));
Y(:,[1:3 12:13])=min(temp(:,2));
t=cell(numel(pieces),1);
x=cell(numel(pieces),1);
% For each piece;
for piece=pieces(:)'
    % Get the node.
    node_idx=piece_node(pieces==piece)+1;
    % Get start position.
    x0=chess.nodes{node_idx}.translation;
    % Get all the moves of the piece.
    [Move,T]=find((game(:,1:2:end)==piece)');
    % If the piece is moved at all;
    if(numel(T)>0)
        t{piece==pieces(:)'}=nan(1,2*numel(T));
        x{piece==pieces(:)'}=nan(2*numel(T),3);
        % Each time it is moved;
        for i=1:numel(T)
            % Get start and end times of the move.
            t{piece==pieces(:)'}(2*i-1)=tstart(T(i),Move(i));
            t{piece==pieces(:)'}(2*i)=tend(T(i),Move(i));
            % If it's the first move of the piece;
            if(i==1)
                % Move starts from start position.
                x{piece==pieces(:)'}(2*i-1,:)=x0;
            else
                % Else move starts from last position.
                x{piece==pieces(:)'}(2*i-1,:)=x{piece==pieces(:)'}(2*i-2,:);
            end
            % Get end position of move.
            position=game(T(i),Move(i)*2);
            % Move ends in end position
            x{piece==pieces(:)'}(2*i,:)=[X(positions==position) Y(positions==position) Z(positions==position)];
        end
        % Stay in final position for 3 seconds for resignation animation.
        t{piece==pieces(:)'}=[t{piece==pieces(:)'} maxt];
        x{piece==pieces(:)'}=x{piece==pieces(:)'}([1:end end],:);
    end
end

% Uncomment to only save last 12 seconds of game.
% for i=1:numel(pieces(:))
%     if(~isempty(t{i}))
%         x{i}=x{i}(find(t{i}<=start_T,1,'last'):end,:);
%         t{i}=max(t{i}(find(t{i}<=start_T,1,'last'):end),start_T)-start_T;
%     end
% end

% Initiate animation samplers and channels.
sampler_count=0;
samplers=[];
channels=[];
% For each piece;
for i=1:numel(pieces(:)')
    % If the piece is moved at all;
    if(~isempty(t{i}))
        % Get node of the piece.
        node_idx=piece_node(i);
        % Add time and translation sampler.
        samplers=[samplers chess.addAnimationSampler(chess.addBinaryData(t{i},"FLOAT","SCALAR",true),chess.addBinaryData(x{i},"FLOAT","VEC3",true))]; %#ok<AGROW>
        % Set the animation channel to node translation.
        channels=[channels chess.addAnimationChannel(sampler_count,node_idx,"translation")]; %#ok<AGROW>
        % Increment sampler count to keep track.
        sampler_count=sampler_count+1;
    end
end

% Get node of resignation king.
node_idx=chess.nodes{piece_node(pieces=="E1")+1}.children{1};
% Get the times for resignation animation.
t=max(tend,[],'all')+(1:3);
% Uncomment to only save last 12 seconds of game.
% t=t-start_T;
% Upon resignation, the king falls 90° on its side, so create rotation
% quaternions.
q=[0 0 0 1;0 0 1/sqrt(2) 1/sqrt(2);0 0 1/sqrt(2) 1/sqrt(2)];

% Add time and rotation sampler.
samplers=[samplers chess.addAnimationSampler(chess.addBinaryData(t,"FLOAT","SCALAR",true),chess.addBinaryData(q,"FLOAT","VEC4",true))];
% Set the animation channel to node rotation.
channels=[channels chess.addAnimationChannel(sampler_count,node_idx,"rotation")];

% Add the animation.
chess.addAnimation(samplers,channels);
% Write GLTF file.
chess.writeGLTF("BeautifulGameOfTheCentury.gltf");
% Write GLB file.
chess.writeGLB("BeautifulGameOfTheCentury.glb");

function [gltf,piece_node]=ABeautifulGame()
    % ABEAUTIFULGAME downloads the GLTF sample chess set and returns the
    % GLTF object and node indexes of the pieces.
    % Set URL to GLTF sample.
    url="https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/ABeautifulGame/glTF/";
    % Download the GLTF file with binary buffer
    gltf_orig=GLTF(url+"ABeautifulGame.gltf");
    disp("Downloaded meshes.");
    % Get nodes which have a parent - these are pawn tops.
    pred=gltf_orig.nodeTree();
    temp=[gltf_orig.nodes{pred~=0}];
    % Get their translation from body nodes.
    dhead=mean([temp.translation],2)';
    
    % Get mesh for chessboard.
    V=gltf_orig.getAccessor(gltf_orig.meshes{5}.primitives{1}.attributes.POSITION);
    N=gltf_orig.getAccessor(gltf_orig.meshes{5}.primitives{1}.attributes.NORMAL);
    UV=gltf_orig.getAccessor(gltf_orig.meshes{5}.primitives{1}.attributes.TEXCOORD_0);
    F=reshape(gltf_orig.getAccessor(gltf_orig.meshes{5}.primitives{1}.indices),3,[])'+1;
    
    % Create a function to get bottom centre of matrix and set that as
    % origin.
    reformat=@(x)(x-[(min(x(:,1))+max(x(:,1)))/2 min(x(:,2)) (min(x(:,3))+max(x(:,3)))/2]);

    % Set the top centre of the board as the origin for that mesh.
    boardbase=mean(V(and(vecnorm(V(:,[1 3]),2,2)==min(vecnorm(V(V(:,2)>0,[1 3]),2,2)),V(:,2)>0),:));
    V=(V-boardbase);

    % Get mesh for the king.
    VK=gltf_orig.getAccessor(gltf_orig.meshes{1}.primitives{1}.attributes.POSITION);
    NK=gltf_orig.getAccessor(gltf_orig.meshes{1}.primitives{1}.attributes.NORMAL);
    UVK=gltf_orig.getAccessor(gltf_orig.meshes{1}.primitives{1}.attributes.TEXCOORD_0);
    FK=reshape(gltf_orig.getAccessor(gltf_orig.meshes{1}.primitives{1}.indices),3,[])'+1;
    VK=reformat(VK);

    % Get mesh for the queen.
    VQ=gltf_orig.getAccessor(gltf_orig.meshes{3}.primitives{1}.attributes.POSITION);
    NQ=gltf_orig.getAccessor(gltf_orig.meshes{3}.primitives{1}.attributes.NORMAL);
    UVQ=gltf_orig.getAccessor(gltf_orig.meshes{3}.primitives{1}.attributes.TEXCOORD_0);
    FQ=reshape(gltf_orig.getAccessor(gltf_orig.meshes{3}.primitives{1}.indices),3,[])'+1;
    VQ=reformat(VQ);

    % Get mesh for the castle.
    VC=gltf_orig.getAccessor(gltf_orig.meshes{10}.primitives{1}.attributes.POSITION);
    NC=gltf_orig.getAccessor(gltf_orig.meshes{10}.primitives{1}.attributes.NORMAL);
    UVC=gltf_orig.getAccessor(gltf_orig.meshes{10}.primitives{1}.attributes.TEXCOORD_0);
    FC=reshape(gltf_orig.getAccessor(gltf_orig.meshes{10}.primitives{1}.indices),3,[])'+1;
    VC=reformat(VC);

    % Get mesh for the knight.
    VN=gltf_orig.getAccessor(gltf_orig.meshes{12}.primitives{1}.attributes.POSITION);
    NN=gltf_orig.getAccessor(gltf_orig.meshes{12}.primitives{1}.attributes.NORMAL);
    UVN=gltf_orig.getAccessor(gltf_orig.meshes{12}.primitives{1}.attributes.TEXCOORD_0);
    FN=reshape(gltf_orig.getAccessor(gltf_orig.meshes{12}.primitives{1}.indices),3,[])'+1;
    VN=reformat(VN);

    % Get mesh for the bishop.
    VB=gltf_orig.getAccessor(gltf_orig.meshes{14}.primitives{1}.attributes.POSITION);
    NB=gltf_orig.getAccessor(gltf_orig.meshes{14}.primitives{1}.attributes.NORMAL);
    UVB=gltf_orig.getAccessor(gltf_orig.meshes{14}.primitives{1}.attributes.TEXCOORD_0);
    FB=reshape(gltf_orig.getAccessor(gltf_orig.meshes{14}.primitives{1}.indices),3,[])'+1;
    VB=reformat(VB);

    % Get mesh for the pawn body.
    VP=gltf_orig.getAccessor(gltf_orig.meshes{7}.primitives{1}.attributes.POSITION);
    NP=gltf_orig.getAccessor(gltf_orig.meshes{7}.primitives{1}.attributes.NORMAL);
    UVP=gltf_orig.getAccessor(gltf_orig.meshes{7}.primitives{1}.attributes.TEXCOORD_0);
    FP=reshape(gltf_orig.getAccessor(gltf_orig.meshes{7}.primitives{1}.indices),3,[])'+1;
    
    % Reset the mesh origin to bottom centre, and save the displacement.
    pawn_base=[(min(VP(:,1))+max(VP(:,1)))/2 min(VP(:,2)) (min(VP(:,3))+max(VP(:,3)))/2];
    VP=(VP-pawn_base);

    % Get mesh for the pawn top, correcting for the displacement from pawn
    % body.
    VP2=gltf_orig.getAccessor(gltf_orig.meshes{6}.primitives{1}.attributes.POSITION)+dhead;
    NP2=gltf_orig.getAccessor(gltf_orig.meshes{6}.primitives{1}.attributes.NORMAL);
    UVP2=gltf_orig.getAccessor(gltf_orig.meshes{6}.primitives{1}.attributes.TEXCOORD_0);
    FP2=reshape(gltf_orig.getAccessor(gltf_orig.meshes{6}.primitives{1}.indices),3,[])'+1;
    % Correct for pawn body centre displacement.
    VP2=(VP2-pawn_base);

    % Get the leftmost vertex of king mesh, to be used for resignation
    % animation.
    rebase=[-0.432083919644356 0 0]/16;

    % Create new GLTF.
    gltf=GLTF();
    % Create the default sampler.
    sampler_idx=gltf.addTextureSampler();
    % Download chessboard textures.
    chessboard_base=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{5}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    chessboard_normal=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{5}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    chessboard_ORM=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{5}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    % Create chessboard material.
    chessboard_mat=gltf.addMaterial('baseColorTextureIdx',chessboard_base,'normalTextureIdx',chessboard_normal,'occlusionTextureIdx',chessboard_ORM,'metallicRoughnessTextureIdx',chessboard_ORM);
    % Create chessboard mesh.
    chessboard_mesh=gltf.addMesh(V,'indices',F,'NORMAL',N,'TEXCOORD',UV,'material',chessboard_mat);
    % Create chessboard node.
    gltf.addNode('mesh',chessboard_mesh);
    disp("Downloaded chessboard textures.");

    % Create functions to generate joints and weights given vertices.
    J=@(x)zeros(size(x,1),4);
    W=@(x)[ones(size(x,1),1) zeros(size(x,1),3)];
    % Create positions grid.
    [X,Z]=meshgrid(-3.5:3.5,[3.5 2.5 -2.5 -3.5]);
    X=X/16;
    Z=Z/16;
    % Create inverse bind matrix.
    ibm=eye(4);
    % Number the pieces and positions
    pieces=[["a1";"b1";"c1";"d1";"e1";"a2"] ["a8";"b8";"c8";"d8";"e8";"a7"]];   
    position_piece=[["a" "b" "c" "d" "e" "c" "b" "a"]+"1";repmat("a",2,8)+[2;7];["a" "b" "c" "d" "e" "c" "b" "a"]+"8"];
    positions=string(num2cell(char(97:104)))+string([1 2 7 8]');
    piece_mesh=nan(size(pieces));
    piece_node=nan(size(positions));

    % Download castle textures.
    castle_white_base=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{11}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    castle_black_base=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{10}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    castle_normal=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{10}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    castle_ORM=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{10}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    % Create castle materials.
    castle_white_mat=gltf.addMaterial('baseColorTextureIdx',castle_white_base,'normalTextureIdx',castle_normal,'occlusionTextureIdx',castle_ORM,'metallicRoughnessTextureIdx',castle_ORM);
    castle_black_mat=gltf.addMaterial('baseColorTextureIdx',castle_black_base,'normalTextureIdx',castle_normal,'occlusionTextureIdx',castle_ORM,'metallicRoughnessTextureIdx',castle_ORM);
    % Create castle mesh.
    piece_mesh(pieces=="a1",1)=gltf.addMesh(VC,'indices',FC,'NORMAL',NC,'material',castle_white_mat,'TEXCOORD',UVC,'WEIGHTS',W(VC),'JOINTS',J(VC));
    % Duplicate castle mesh for black piece.
    gltf.meshes=gltf.meshes([1:end end]);
    piece_mesh(pieces=="a1",2)=piece_mesh(pieces=="a1",1)+1;
    % Use black material for black piece.
    gltf.meshes{end}.primitives{1}.material=castle_black_mat;
    disp("Downloaded castle textures.");
    
    % Download knight textures.
    knight_white_base=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{13}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    knight_black_base=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{12}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    knight_normal=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{12}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    knight_ORM=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{12}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    % Create knight materials.
    knight_white_mat=gltf.addMaterial('baseColorTextureIdx',knight_white_base,'normalTextureIdx',knight_normal,'occlusionTextureIdx',knight_ORM,'metallicRoughnessTextureIdx',knight_ORM);
    knight_black_mat=gltf.addMaterial('baseColorTextureIdx',knight_black_base,'normalTextureIdx',knight_normal,'occlusionTextureIdx',knight_ORM,'metallicRoughnessTextureIdx',knight_ORM);
    % Create knight mesh.
    piece_mesh(pieces=="b1",1)=gltf.addMesh(VN,'indices',FN,'NORMAL',NN,'material',knight_white_mat,'TEXCOORD',UVN,'WEIGHTS',W(VN),'JOINTS',J(VN));
    % Duplicate knight mesh for black piece.
    gltf.meshes=gltf.meshes([1:end end]);
    piece_mesh(pieces=="b1",2)=piece_mesh(pieces=="b1",1)+1;
    % Use black material for black piece.
    gltf.meshes{end}.primitives{1}.material=knight_black_mat;
    disp("Downloaded knight textures.");

    % Download bishop textures.
    bishop_white_base=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{15}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    bishop_black_base=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{14}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    bishop_white_normal=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{15}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    bishop_black_normal=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{14}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    bishop_white_ORM=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{15}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    bishop_black_ORM=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{14}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    % Create bishop materials.
    bishop_white_mat=gltf.addMaterial('baseColorTextureIdx',bishop_white_base,'normalTextureIdx',bishop_white_normal,'occlusionTextureIdx',bishop_white_ORM,'metallicRoughnessTextureIdx',bishop_white_ORM);
    bishop_black_mat=gltf.addMaterial('baseColorTextureIdx',bishop_black_base,'normalTextureIdx',bishop_black_normal,'occlusionTextureIdx',bishop_black_ORM,'metallicRoughnessTextureIdx',bishop_black_ORM);
    % Create bishop mesh.
    piece_mesh(pieces=="c1",1)=gltf.addMesh(VB,'indices',FB,'NORMAL',NB,'material',bishop_white_mat,'TEXCOORD',UVB,'WEIGHTS',W(VB),'JOINTS',J(VB));
    % Duplicate bishop mesh for black piece.
    gltf.meshes=gltf.meshes([1:end end]);
    piece_mesh(pieces=="c1",2)=piece_mesh(pieces=="c1",1)+1;
    % Use black material for black piece.
    gltf.meshes{end}.primitives{1}.material=bishop_black_mat;
    disp("Downloaded bishop textures.");

    % Download queen textures.
    queen_white_base=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{4}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    queen_black_base=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{3}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    queen_white_normal=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{4}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    queen_black_normal=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{3}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    queen_white_ORM=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{4}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    queen_black_ORM=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{3}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    % Create queen materials.
    queen_white_mat=gltf.addMaterial('baseColorTextureIdx',queen_white_base,'normalTextureIdx',queen_white_normal,'occlusionTextureIdx',queen_white_ORM,'metallicRoughnessTextureIdx',queen_white_ORM);
    queen_black_mat=gltf.addMaterial('baseColorTextureIdx',queen_black_base,'normalTextureIdx',queen_black_normal,'occlusionTextureIdx',queen_black_ORM,'metallicRoughnessTextureIdx',queen_black_ORM);
    % Create queen mesh.
    piece_mesh(pieces=="d1",1)=gltf.addMesh(VQ,'indices',FQ,'NORMAL',NQ,'material',queen_white_mat,'TEXCOORD',UVQ,'WEIGHTS',W(VQ),'JOINTS',J(VQ));
    % Duplicate queen mesh for black piece.
    gltf.meshes=gltf.meshes([1:end end]);
    piece_mesh(pieces=="d1",2)=piece_mesh(pieces=="d1",1)+1;
    % Use black material for black piece.
    gltf.meshes{end}.primitives{1}.material=queen_black_mat;
    disp("Downloaded queen textures.");

    % Download king textures.
    king_white_base=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{2}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    king_black_base=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{1}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    king_white_normal=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{2}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    king_black_normal=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{1}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    king_white_ORM=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{2}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    king_black_ORM=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{1}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    % Create king materials.
    king_white_mat=gltf.addMaterial('baseColorTextureIdx',king_white_base,'normalTextureIdx',king_white_normal,'occlusionTextureIdx',king_white_ORM,'metallicRoughnessTextureIdx',king_white_ORM);
    king_black_mat=gltf.addMaterial('baseColorTextureIdx',king_black_base,'normalTextureIdx',king_black_normal,'occlusionTextureIdx',king_black_ORM,'metallicRoughnessTextureIdx',king_black_ORM);
    % Create king mesh, but use JOINT 2 instead of 0 to account for
    % rotation node.
    piece_mesh(pieces=="e1",1)=gltf.addMesh(VK,'indices',FK,'NORMAL',NK,'material',king_white_mat,'TEXCOORD',UVK,'WEIGHTS',W(VK),'JOINTS',2*W(VK));
    % Duplicate king mesh for black piece.
    gltf.meshes=gltf.meshes([1:end end]);
    piece_mesh(pieces=="e1",2)=piece_mesh(pieces=="e1",1)+1;
    % Use black material for black piece.
    gltf.meshes{end}.primitives{1}.material=king_black_mat;
    disp("Downloaded king textures.");

    % Download pawn textures.
    pawn_white_base=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{7}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    pawn_black_base=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{9}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    pawn_normal=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{7}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    pawn_ORM=gltf.addTexture(url+string(gltf_orig.images{gltf_orig.textures{gltf_orig.materials{gltf_orig.meshes{7}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx);
    % Create pawn materials.
    pawn_white_mat=gltf.addMaterial('baseColorTextureIdx',pawn_white_base,'normalTextureIdx',pawn_normal,'occlusionTextureIdx',pawn_ORM,'metallicRoughnessTextureIdx',pawn_ORM);
    pawn_black_mat=gltf.addMaterial('baseColorTextureIdx',pawn_black_base,'normalTextureIdx',pawn_normal,'occlusionTextureIdx',pawn_ORM,'metallicRoughnessTextureIdx',pawn_ORM);
    pawn_white_top_mat=gltf.addMaterial('baseColorFactor',[1 1 0.828 1],'normalTextureIdx',pawn_normal,'metallicRoughnessTextureIdx',pawn_ORM,'transmissionFactor',gltf_orig.materials{gltf_orig.meshes{6}.primitives{1}.material+1}.extensions.KHR_materials_transmission.transmissionFactor,'thicknessFactor',gltf_orig.materials{gltf_orig.meshes{6}.primitives{1}.material+1}.extensions.KHR_materials_volume.thicknessFactor,'attenuationColor',gltf_orig.materials{gltf_orig.meshes{6}.primitives{1}.material+1}.extensions.KHR_materials_volume.attenuationColor);
    pawn_black_top_mat=gltf.addMaterial('baseColorFactor',[0.3 0.5 0.45 1],'normalTextureIdx',pawn_normal,'metallicRoughnessTextureIdx',pawn_ORM,'transmissionFactor',gltf_orig.materials{gltf_orig.meshes{8}.primitives{1}.material+1}.extensions.KHR_materials_transmission.transmissionFactor,'thicknessFactor',gltf_orig.materials{gltf_orig.meshes{8}.primitives{1}.material+1}.extensions.KHR_materials_volume.thicknessFactor,'attenuationColor',gltf_orig.materials{gltf_orig.meshes{8}.primitives{1}.material+1}.extensions.KHR_materials_volume.attenuationColor);
    % Create pawn body mesh.
    piece_mesh(pieces=="a2",1)=gltf.addMesh(VP,'indices',FP,'NORMAL',NP,'material',pawn_white_mat,'TEXCOORD',UVP,'WEIGHTS',W(VP),'JOINTS',J(VP));
    % Add pawn top mesh.
    gltf.addPrimitiveToMesh(piece_mesh(pieces=="a2",1),VP2,'indices',FP2,'NORMAL',NP2,'material',pawn_white_top_mat,'TEXCOORD',UVP2,'WEIGHTS',W(VP2),'JOINTS',J(VP2));
    % Duplicate pawn mesh for black piece.
    gltf.meshes=gltf.meshes([1:end end]);
    piece_mesh(pieces=="a2",2)=piece_mesh(pieces=="a2",1)+1;
    % Use black materials for black piece.
    gltf.meshes{end}.primitives{1}.material=pawn_black_mat;
    gltf.meshes{end}.primitives{2}.material=pawn_black_top_mat;
    disp("Downloaded pawn textures.");

    % Place castle nodes at start positions.
    piece_node(positions=="a1")=gltf.addNode('addToScene',false,'translation',[X(positions=="a1") 0 Z(positions=="a1")]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a1"==positions)),'skin',gltf.addSkin(piece_node(positions=="a1"),'inverseBindMatrices',ibm),'children',piece_node(positions=="a1"));
    piece_node(positions=="h1")=gltf.addNode('addToScene',false,'translation',[X(positions=="h1") 0 Z(positions=="h1")]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a1"==positions)),'skin',gltf.addSkin(piece_node(positions=="h1"),'inverseBindMatrices',ibm),'children',piece_node(positions=="h1"));
    piece_node(positions=="a8")=gltf.addNode('addToScene',false,'translation',[X(positions=="a8") 0 Z(positions=="a8")],'rotation',[0 1 0 0]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a8"==positions)),'skin',gltf.addSkin(piece_node(positions=="a8"),'inverseBindMatrices',ibm),'children',piece_node(positions=="a8"));
    piece_node(positions=="h8")=gltf.addNode('addToScene',false,'translation',[X(positions=="h8") 0 Z(positions=="h8")],'rotation',[0 1 0 0]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a8"==positions)),'skin',gltf.addSkin(piece_node(positions=="h8"),'inverseBindMatrices',ibm),'children',piece_node(positions=="h8"));

    % Place knight nodes at start positions.
    piece_node(positions=="b1")=gltf.addNode('addToScene',false,'translation',[X(positions=="b1") 0 Z(positions=="b1")]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("b1"==positions)),'skin',gltf.addSkin(piece_node(positions=="b1"),'inverseBindMatrices',ibm),'children',piece_node(positions=="b1"));
    piece_node(positions=="g1")=gltf.addNode('addToScene',false,'translation',[X(positions=="g1") 0 Z(positions=="g1")]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("b1"==positions)),'skin',gltf.addSkin(piece_node(positions=="g1"),'inverseBindMatrices',ibm),'children',piece_node(positions=="g1"));
    piece_node(positions=="b8")=gltf.addNode('addToScene',false,'translation',[X(positions=="b8") 0 Z(positions=="b8")],'rotation',[0 1 0 0]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("b8"==positions)),'skin',gltf.addSkin(piece_node(positions=="b8"),'inverseBindMatrices',ibm),'children',piece_node(positions=="b8"));
    piece_node(positions=="g8")=gltf.addNode('addToScene',false,'translation',[X(positions=="g8") 0 Z(positions=="g8")],'rotation',[0 1 0 0]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("b8"==positions)),'skin',gltf.addSkin(piece_node(positions=="g8"),'inverseBindMatrices',ibm),'children',piece_node(positions=="g8"));

    % Place bishop nodes at start positions.
    piece_node(positions=="c1")=gltf.addNode('addToScene',false,'translation',[X(positions=="c1") 0 Z(positions=="c1")]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("c1"==positions)),'skin',gltf.addSkin(piece_node(positions=="c1"),'inverseBindMatrices',ibm),'children',piece_node(positions=="c1"));
    piece_node(positions=="f1")=gltf.addNode('addToScene',false,'translation',[X(positions=="f1") 0 Z(positions=="f1")]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("c1"==positions)),'skin',gltf.addSkin(piece_node(positions=="f1"),'inverseBindMatrices',ibm),'children',piece_node(positions=="f1"));
    piece_node(positions=="c8")=gltf.addNode('addToScene',false,'translation',[X(positions=="c8") 0 Z(positions=="c8")],'rotation',[0 1 0 0]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("c8"==positions)),'skin',gltf.addSkin(piece_node(positions=="c8"),'inverseBindMatrices',ibm),'children',piece_node(positions=="c8"));
    piece_node(positions=="f8")=gltf.addNode('addToScene',false,'translation',[X(positions=="f8") 0 Z(positions=="f8")],'rotation',[0 1 0 0]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("c8"==positions)),'skin',gltf.addSkin(piece_node(positions=="f8"),'inverseBindMatrices',ibm),'children',piece_node(positions=="f8"));

    % Place castle nodes at start positions.
    piece_node(positions=="d1")=gltf.addNode('addToScene',false,'translation',[X(positions=="d1") 0 Z(positions=="d1")]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("d1"==positions)),'skin',gltf.addSkin(piece_node(positions=="d1"),'inverseBindMatrices',ibm),'children',piece_node(positions=="d1"));
    piece_node(positions=="d8")=gltf.addNode('addToScene',false,'translation',[X(positions=="d8") 0 Z(positions=="d8")],'rotation',[0 1 0 0]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("d8"==positions)),'skin',gltf.addSkin(piece_node(positions=="d8"),'inverseBindMatrices',ibm),'children',piece_node(positions=="d8"));

    % Place king nodes at start positions, but account for extra rotation
    % nodes for resignation animation.
    basenode=gltf.addNode('addToScene',false,'translation',-rebase);
    piecerotation=gltf.addNode('addToScene',false,'children',basenode,'translation',rebase);
    piece_node(positions=="e1")=gltf.addNode('addToScene',false,'children',piecerotation,'translation',[X(positions=="e1") 0 Z(positions=="e1")]);
    ibm2=[eye(3) -rebase';zeros(1,3) 1];
    ibmfull=cat(3,ibm,ibm2,ibm);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("e1"==positions)),'skin',gltf.addSkin([piece_node(positions=="e1") piecerotation basenode],'inverseBindMatrices',ibmfull),'children',piece_node(positions=="e1"));
    basenode=gltf.addNode('addToScene',false,'translation',-rebase,'rotation',[0 1 0 0]);
    piecerotation=gltf.addNode('addToScene',false,'children',basenode,'translation',rebase);
    piece_node(positions=="e8")=gltf.addNode('addToScene',false,'children',piecerotation,'translation',[X(positions=="e8") 0 Z(positions=="e8")]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("e8"==positions)),'skin',gltf.addSkin([piece_node(positions=="e1") piecerotation basenode],'inverseBindMatrices',ibmfull),'children',piece_node(positions=="e8"));

    % Place pawn nodes at start positions.
    piece_node(positions=="a2")=gltf.addNode('addToScene',false,'translation',[X(positions=="a2") 0 Z(positions=="a2")]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a2"==positions)),'skin',gltf.addSkin(piece_node(positions=="a2"),'inverseBindMatrices',ibm),'children',piece_node(positions=="a2"));
    piece_node(positions=="b2")=gltf.addNode('addToScene',false,'translation',[X(positions=="b2") 0 Z(positions=="b2")]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a2"==positions)),'skin',gltf.addSkin(piece_node(positions=="b2"),'inverseBindMatrices',ibm),'children',piece_node(positions=="b2"));
    piece_node(positions=="c2")=gltf.addNode('addToScene',false,'translation',[X(positions=="c2") 0 Z(positions=="c2")]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a2"==positions)),'skin',gltf.addSkin(piece_node(positions=="c2"),'inverseBindMatrices',ibm),'children',piece_node(positions=="c2"));
    piece_node(positions=="d2")=gltf.addNode('addToScene',false,'translation',[X(positions=="d2") 0 Z(positions=="d2")]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a2"==positions)),'skin',gltf.addSkin(piece_node(positions=="d2"),'inverseBindMatrices',ibm),'children',piece_node(positions=="d2"));
    piece_node(positions=="e2")=gltf.addNode('addToScene',false,'translation',[X(positions=="e2") 0 Z(positions=="e2")]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a2"==positions)),'skin',gltf.addSkin(piece_node(positions=="e2"),'inverseBindMatrices',ibm),'children',piece_node(positions=="e2"));
    piece_node(positions=="f2")=gltf.addNode('addToScene',false,'translation',[X(positions=="f2") 0 Z(positions=="f2")]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a2"==positions)),'skin',gltf.addSkin(piece_node(positions=="f2"),'inverseBindMatrices',ibm),'children',piece_node(positions=="f2"));
    piece_node(positions=="g2")=gltf.addNode('addToScene',false,'translation',[X(positions=="g2") 0 Z(positions=="g2")]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a2"==positions)),'skin',gltf.addSkin(piece_node(positions=="g2"),'inverseBindMatrices',ibm),'children',piece_node(positions=="g2"));
    piece_node(positions=="h2")=gltf.addNode('addToScene',false,'translation',[X(positions=="h2") 0 Z(positions=="h2")]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a2"==positions)),'skin',gltf.addSkin(piece_node(positions=="h2"),'inverseBindMatrices',ibm),'children',piece_node(positions=="h2"));
    piece_node(positions=="a7")=gltf.addNode('addToScene',false,'translation',[X(positions=="a7") 0 Z(positions=="a7")],'rotation',[0 1 0 0]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a7"==positions)),'skin',gltf.addSkin(piece_node(positions=="a7"),'inverseBindMatrices',ibm),'children',piece_node(positions=="a7"));
    piece_node(positions=="b7")=gltf.addNode('addToScene',false,'translation',[X(positions=="b7") 0 Z(positions=="b7")],'rotation',[0 1 0 0]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a7"==positions)),'skin',gltf.addSkin(piece_node(positions=="b7"),'inverseBindMatrices',ibm),'children',piece_node(positions=="b7"));
    piece_node(positions=="c7")=gltf.addNode('addToScene',false,'translation',[X(positions=="c7") 0 Z(positions=="c7")],'rotation',[0 1 0 0]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a7"==positions)),'skin',gltf.addSkin(piece_node(positions=="c7"),'inverseBindMatrices',ibm),'children',piece_node(positions=="c7"));
    piece_node(positions=="d7")=gltf.addNode('addToScene',false,'translation',[X(positions=="d7") 0 Z(positions=="d7")],'rotation',[0 1 0 0]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a7"==positions)),'skin',gltf.addSkin(piece_node(positions=="d7"),'inverseBindMatrices',ibm),'children',piece_node(positions=="d7"));
    piece_node(positions=="e7")=gltf.addNode('addToScene',false,'translation',[X(positions=="e7") 0 Z(positions=="e7")],'rotation',[0 1 0 0]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a7"==positions)),'skin',gltf.addSkin(piece_node(positions=="e7"),'inverseBindMatrices',ibm),'children',piece_node(positions=="e7"));
    piece_node(positions=="f7")=gltf.addNode('addToScene',false,'translation',[X(positions=="f7") 0 Z(positions=="f7")],'rotation',[0 1 0 0]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a7"==positions)),'skin',gltf.addSkin(piece_node(positions=="f7"),'inverseBindMatrices',ibm),'children',piece_node(positions=="f7"));
    piece_node(positions=="g7")=gltf.addNode('addToScene',false,'translation',[X(positions=="g7") 0 Z(positions=="g7")],'rotation',[0 1 0 0]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a7"==positions)),'skin',gltf.addSkin(piece_node(positions=="g7"),'inverseBindMatrices',ibm),'children',piece_node(positions=="g7"));
    piece_node(positions=="h7")=gltf.addNode('addToScene',false,'translation',[X(positions=="h7") 0 Z(positions=="h7")],'rotation',[0 1 0 0]);
    gltf.addNode('mesh',piece_mesh(pieces==position_piece("a7"==positions)),'skin',gltf.addSkin(piece_node(positions=="h7"),'inverseBindMatrices',ibm),'children',piece_node(positions=="h7"));
end
