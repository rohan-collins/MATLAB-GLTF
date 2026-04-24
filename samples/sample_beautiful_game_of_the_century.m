% Download "A Beautiful Game" chess set.
[chess,piece_node,promotion_nodes]=ABeautifulGame('url',"chess/",'embedTexture',false);
% Initiate a new buffer to separate the game resources from animations.
chess.buffers{2}=uint8([]);
% Add the animation for Byrne vs Fischer (1956).
chess=addChessAnimation(chess,piece_node,promotion_nodes,"gameofthecentury.pgn",'name',"Game of the Century");
% Add the animation for Fellowes vs Lalić (2024).
chess=addChessAnimation(chess,piece_node,promotion_nodes,"game_2753406.pgn",'name',"Longest Game");
% Write GLTF file.
chess.writeGLTF("chess/BeautifulGameOfTheCentury.gltf",'bufferFile',"chess/BeautifulGameOfTheCentury.bin");
% Write GLB file.
chess.writeGLB("chess/BeautifulGameOfTheCentury.glb");

function [obj,piece_node,promotion_nodes]=ABeautifulGame(varargin)
    % ABEAUTIFULGAME downloads the GLTF sample chess set and returns the
    % GLTF object and node indexes of the pieces.
    ips=inputParser;
    ips.addParameter('url',"https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/ABeautifulGame/glTF/",@isstring);
    ips.addParameter('embedTexture',true,@islogical);
    ips.parse(varargin{:});
    parameters=ips.Results;
    url=parameters.url;
    embedTexture=parameters.embedTexture;

    % Set URL to GLTF sample.
    % Download the GLTF file with binary buffer
    obj_orig=gltf.GLTF(url+"ABeautifulGame.gltf");
    disp("Downloaded meshes.");
    % Get nodes which have a parent - these are pawn tops.
    pred=obj_orig.nodeTree();
    temp=[obj_orig.nodes{pred~=0}];
    % Get their translation from body nodes.
    dhead=mean([temp.translation],2)';

    % Get mesh for chessboard.
    V=obj_orig.getAccessor(obj_orig.meshes{5}.primitives{1}.attributes.POSITION);
    N=obj_orig.getAccessor(obj_orig.meshes{5}.primitives{1}.attributes.NORMAL);
    UV=obj_orig.getAccessor(obj_orig.meshes{5}.primitives{1}.attributes.TEXCOORD_0);
    F=reshape(obj_orig.getAccessor(obj_orig.meshes{5}.primitives{1}.indices),3,[])'+1;
    
    % Create a function to get bottom centre of matrix and set that as
    % origin.
    reformat=@(x)(x-[(min(x(:,1))+max(x(:,1)))/2 min(x(:,2)) (min(x(:,3))+max(x(:,3)))/2]);

    % Set the top centre of the board as the origin for that mesh.
    boardbase=mean(V(and(vecnorm(V(:,[1 3]),2,2)==min(vecnorm(V(V(:,2)>0,[1 3]),2,2)),V(:,2)>0),:));
    V=(V-boardbase);

    % Get mesh for the king.
    VK=obj_orig.getAccessor(obj_orig.meshes{1}.primitives{1}.attributes.POSITION);
    NK=obj_orig.getAccessor(obj_orig.meshes{1}.primitives{1}.attributes.NORMAL);
    UVK=obj_orig.getAccessor(obj_orig.meshes{1}.primitives{1}.attributes.TEXCOORD_0);
    FK=reshape(obj_orig.getAccessor(obj_orig.meshes{1}.primitives{1}.indices),3,[])'+1;
    VK=reformat(VK);

    % Get mesh for the queen.
    VQ=obj_orig.getAccessor(obj_orig.meshes{3}.primitives{1}.attributes.POSITION);
    NQ=obj_orig.getAccessor(obj_orig.meshes{3}.primitives{1}.attributes.NORMAL);
    UVQ=obj_orig.getAccessor(obj_orig.meshes{3}.primitives{1}.attributes.TEXCOORD_0);
    FQ=reshape(obj_orig.getAccessor(obj_orig.meshes{3}.primitives{1}.indices),3,[])'+1;
    VQ=reformat(VQ);

    % Get mesh for the castle.
    VC=obj_orig.getAccessor(obj_orig.meshes{10}.primitives{1}.attributes.POSITION);
    NC=obj_orig.getAccessor(obj_orig.meshes{10}.primitives{1}.attributes.NORMAL);
    UVC=obj_orig.getAccessor(obj_orig.meshes{10}.primitives{1}.attributes.TEXCOORD_0);
    FC=reshape(obj_orig.getAccessor(obj_orig.meshes{10}.primitives{1}.indices),3,[])'+1;
    VC=reformat(VC);

    % Get mesh for the knight.
    VN=obj_orig.getAccessor(obj_orig.meshes{12}.primitives{1}.attributes.POSITION);
    NN=obj_orig.getAccessor(obj_orig.meshes{12}.primitives{1}.attributes.NORMAL);
    UVN=obj_orig.getAccessor(obj_orig.meshes{12}.primitives{1}.attributes.TEXCOORD_0);
    FN=reshape(obj_orig.getAccessor(obj_orig.meshes{12}.primitives{1}.indices),3,[])'+1;
    VN=reformat(VN);

    % Get mesh for the bishop.
    VB=obj_orig.getAccessor(obj_orig.meshes{14}.primitives{1}.attributes.POSITION);
    NB=obj_orig.getAccessor(obj_orig.meshes{14}.primitives{1}.attributes.NORMAL);
    UVB=obj_orig.getAccessor(obj_orig.meshes{14}.primitives{1}.attributes.TEXCOORD_0);
    FB=reshape(obj_orig.getAccessor(obj_orig.meshes{14}.primitives{1}.indices),3,[])'+1;
    VB=reformat(VB);

    % Get mesh for the pawn body.
    VP=obj_orig.getAccessor(obj_orig.meshes{7}.primitives{1}.attributes.POSITION);
    NP=obj_orig.getAccessor(obj_orig.meshes{7}.primitives{1}.attributes.NORMAL);
    UVP=obj_orig.getAccessor(obj_orig.meshes{7}.primitives{1}.attributes.TEXCOORD_0);
    FP=reshape(obj_orig.getAccessor(obj_orig.meshes{7}.primitives{1}.indices),3,[])'+1;
    
    % Reset the mesh origin to bottom centre, and save the displacement.
    pawn_base=[(min(VP(:,1))+max(VP(:,1)))/2 min(VP(:,2)) (min(VP(:,3))+max(VP(:,3)))/2];
    VP=(VP-pawn_base);

    % Get mesh for the pawn top, correcting for the displacement from pawn
    % body.
    VP2=obj_orig.getAccessor(obj_orig.meshes{6}.primitives{1}.attributes.POSITION)+dhead;
    NP2=obj_orig.getAccessor(obj_orig.meshes{6}.primitives{1}.attributes.NORMAL);
    UVP2=obj_orig.getAccessor(obj_orig.meshes{6}.primitives{1}.attributes.TEXCOORD_0);
    FP2=reshape(obj_orig.getAccessor(obj_orig.meshes{6}.primitives{1}.indices),3,[])'+1;
    % Correct for pawn body centre displacement.
    VP2=(VP2-pawn_base);

    % Get the leftmost vertex of king mesh, to be used for resignation
    % animation.
    rebase=[-0.432083919644356 0 0]/16;

    % Create new GLTF.
    obj=gltf.GLTF();
    obj.asset.copyright=obj_orig.asset.copyright;
    % Create the default sampler.
    sampler_idx=obj.addTextureSampler();
    % Download chessboard textures.
    chessboard_base=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{5}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    chessboard_normal=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{5}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    chessboard_ORM=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{5}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    % Create chessboard material.
    chessboard_mat=obj.addMaterial('baseColorTextureIdx',chessboard_base,'normalTextureIdx',chessboard_normal,'occlusionTextureIdx',chessboard_ORM,'metallicRoughnessTextureIdx',chessboard_ORM);
    % Create chessboard mesh.
    chessboard_mesh=obj.addMesh(V,'indices',F,'NORMAL',N,'TEXCOORD',UV,'material',chessboard_mat);
    % Create chessboard node.
    obj.addNode('mesh',chessboard_mesh);
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
    castle_white_base=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{11}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    castle_black_base=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{10}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    castle_normal=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{10}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    castle_ORM=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{10}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    % Create castle materials.
    castle_white_mat=obj.addMaterial('baseColorTextureIdx',castle_white_base,'normalTextureIdx',castle_normal,'occlusionTextureIdx',castle_ORM,'metallicRoughnessTextureIdx',castle_ORM);
    castle_black_mat=obj.addMaterial('baseColorTextureIdx',castle_black_base,'normalTextureIdx',castle_normal,'occlusionTextureIdx',castle_ORM,'metallicRoughnessTextureIdx',castle_ORM);
    % Create castle mesh.
    piece_mesh(pieces=="a1",1)=obj.addMesh(VC,'indices',FC,'NORMAL',NC,'material',castle_white_mat,'TEXCOORD',UVC,'WEIGHTS',W(VC),'JOINTS',J(VC));
    % Duplicate castle mesh for black piece.
    obj.meshes=obj.meshes([1:end end]);
    piece_mesh(pieces=="a1",2)=piece_mesh(pieces=="a1",1)+1;
    % Use black material for black piece.
    obj.meshes{end}.primitives{1}.material=castle_black_mat;
    disp("Downloaded castle textures.");
    
    % Download knight textures.
    knight_white_base=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{13}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    knight_black_base=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{12}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    knight_normal=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{12}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    knight_ORM=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{12}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    % Create knight materials.
    knight_white_mat=obj.addMaterial('baseColorTextureIdx',knight_white_base,'normalTextureIdx',knight_normal,'occlusionTextureIdx',knight_ORM,'metallicRoughnessTextureIdx',knight_ORM);
    knight_black_mat=obj.addMaterial('baseColorTextureIdx',knight_black_base,'normalTextureIdx',knight_normal,'occlusionTextureIdx',knight_ORM,'metallicRoughnessTextureIdx',knight_ORM);
    % Create knight mesh.
    piece_mesh(pieces=="b1",1)=obj.addMesh(VN,'indices',FN,'NORMAL',NN,'material',knight_white_mat,'TEXCOORD',UVN,'WEIGHTS',W(VN),'JOINTS',J(VN));
    % Duplicate knight mesh for black piece.
    obj.meshes=obj.meshes([1:end end]);
    piece_mesh(pieces=="b1",2)=piece_mesh(pieces=="b1",1)+1;
    % Use black material for black piece.
    obj.meshes{end}.primitives{1}.material=knight_black_mat;
    disp("Downloaded knight textures.");

    % Download bishop textures.
    bishop_white_base=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{15}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    bishop_black_base=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{14}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    bishop_white_normal=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{15}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    bishop_black_normal=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{14}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    bishop_white_ORM=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{15}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    bishop_black_ORM=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{14}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    % Create bishop materials.
    bishop_white_mat=obj.addMaterial('baseColorTextureIdx',bishop_white_base,'normalTextureIdx',bishop_white_normal,'occlusionTextureIdx',bishop_white_ORM,'metallicRoughnessTextureIdx',bishop_white_ORM);
    bishop_black_mat=obj.addMaterial('baseColorTextureIdx',bishop_black_base,'normalTextureIdx',bishop_black_normal,'occlusionTextureIdx',bishop_black_ORM,'metallicRoughnessTextureIdx',bishop_black_ORM);
    % Create bishop mesh.
    piece_mesh(pieces=="c1",1)=obj.addMesh(VB,'indices',FB,'NORMAL',NB,'material',bishop_white_mat,'TEXCOORD',UVB,'WEIGHTS',W(VB),'JOINTS',J(VB));
    % Duplicate bishop mesh for black piece.
    obj.meshes=obj.meshes([1:end end]);
    piece_mesh(pieces=="c1",2)=piece_mesh(pieces=="c1",1)+1;
    % Use black material for black piece.
    obj.meshes{end}.primitives{1}.material=bishop_black_mat;
    disp("Downloaded bishop textures.");

    % Download queen textures.
    queen_white_base=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{4}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    queen_black_base=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{3}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    queen_white_normal=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{4}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    queen_black_normal=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{3}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    queen_white_ORM=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{4}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    queen_black_ORM=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{3}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    % Create queen materials.
    queen_white_mat=obj.addMaterial('baseColorTextureIdx',queen_white_base,'normalTextureIdx',queen_white_normal,'occlusionTextureIdx',queen_white_ORM,'metallicRoughnessTextureIdx',queen_white_ORM);
    queen_black_mat=obj.addMaterial('baseColorTextureIdx',queen_black_base,'normalTextureIdx',queen_black_normal,'occlusionTextureIdx',queen_black_ORM,'metallicRoughnessTextureIdx',queen_black_ORM);
    % Create queen mesh.
    piece_mesh(pieces=="d1",1)=obj.addMesh(VQ,'indices',FQ,'NORMAL',NQ,'material',queen_white_mat,'TEXCOORD',UVQ,'WEIGHTS',W(VQ),'JOINTS',J(VQ));
    % Duplicate queen mesh for black piece.
    obj.meshes=obj.meshes([1:end end]);
    piece_mesh(pieces=="d1",2)=piece_mesh(pieces=="d1",1)+1;
    % Use black material for black piece.
    obj.meshes{end}.primitives{1}.material=queen_black_mat;
    disp("Downloaded queen textures.");

    % Download king textures.
    king_white_base=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{2}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    king_black_base=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{1}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    king_white_normal=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{2}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    king_black_normal=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{1}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    king_white_ORM=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{2}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    king_black_ORM=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{1}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    % Create king materials.
    king_white_mat=obj.addMaterial('baseColorTextureIdx',king_white_base,'normalTextureIdx',king_white_normal,'occlusionTextureIdx',king_white_ORM,'metallicRoughnessTextureIdx',king_white_ORM);
    king_black_mat=obj.addMaterial('baseColorTextureIdx',king_black_base,'normalTextureIdx',king_black_normal,'occlusionTextureIdx',king_black_ORM,'metallicRoughnessTextureIdx',king_black_ORM);
    % Create king mesh, but use JOINT 2 instead of 0 to account for
    % rotation node.
    piece_mesh(pieces=="e1",1)=obj.addMesh(VK,'indices',FK,'NORMAL',NK,'material',king_white_mat,'TEXCOORD',UVK,'WEIGHTS',W(VK),'JOINTS',2*W(VK));
    % Duplicate king mesh for black piece.
    obj.meshes=obj.meshes([1:end end]);
    piece_mesh(pieces=="e1",2)=piece_mesh(pieces=="e1",1)+1;
    % Use black material for black piece.
    obj.meshes{end}.primitives{1}.material=king_black_mat;
    disp("Downloaded king textures.");

    % Download pawn textures.
    pawn_white_base=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{7}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    pawn_black_base=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{9}.primitives{1}.material+1}.pbrMetallicRoughness.baseColorTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    pawn_normal=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{7}.primitives{1}.material+1}.normalTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    pawn_ORM=obj.addTexture(url+string(obj_orig.images{obj_orig.textures{obj_orig.materials{obj_orig.meshes{7}.primitives{1}.material+1}.pbrMetallicRoughness.metallicRoughnessTexture.index+1}.source+1}.uri),'sampler',sampler_idx,'embedTexture',embedTexture);
    % Create pawn materials.
    pawn_white_mat=obj.addMaterial('baseColorTextureIdx',pawn_white_base,'normalTextureIdx',pawn_normal,'occlusionTextureIdx',pawn_ORM,'metallicRoughnessTextureIdx',pawn_ORM);
    pawn_black_mat=obj.addMaterial('baseColorTextureIdx',pawn_black_base,'normalTextureIdx',pawn_normal,'occlusionTextureIdx',pawn_ORM,'metallicRoughnessTextureIdx',pawn_ORM);
    pawn_white_top_mat=obj.addMaterial('baseColorFactor',[1 1 0.828 1],'normalTextureIdx',pawn_normal,'metallicRoughnessTextureIdx',pawn_ORM,'transmissionFactor',obj_orig.materials{obj_orig.meshes{6}.primitives{1}.material+1}.extensions.KHR_materials_transmission.transmissionFactor,'thicknessFactor',obj_orig.materials{obj_orig.meshes{6}.primitives{1}.material+1}.extensions.KHR_materials_volume.thicknessFactor,'attenuationColor',obj_orig.materials{obj_orig.meshes{6}.primitives{1}.material+1}.extensions.KHR_materials_volume.attenuationColor);
    pawn_black_top_mat=obj.addMaterial('baseColorFactor',[0.3 0.5 0.45 1],'normalTextureIdx',pawn_normal,'metallicRoughnessTextureIdx',pawn_ORM,'transmissionFactor',obj_orig.materials{obj_orig.meshes{8}.primitives{1}.material+1}.extensions.KHR_materials_transmission.transmissionFactor,'thicknessFactor',obj_orig.materials{obj_orig.meshes{8}.primitives{1}.material+1}.extensions.KHR_materials_volume.thicknessFactor,'attenuationColor',obj_orig.materials{obj_orig.meshes{8}.primitives{1}.material+1}.extensions.KHR_materials_volume.attenuationColor);
    % Create pawn body mesh.
    piece_mesh(pieces=="a2",1)=obj.addMesh(VP,'indices',FP,'NORMAL',NP,'material',pawn_white_mat,'TEXCOORD',UVP,'WEIGHTS',W(VP),'JOINTS',W(VP));
    % Add pawn top mesh.
    obj.addPrimitiveToMesh(piece_mesh(pieces=="a2",1),VP2,'indices',FP2,'NORMAL',NP2,'material',pawn_white_top_mat,'TEXCOORD',UVP2,'WEIGHTS',W(VP2),'JOINTS',W(VP2));

    obj.meshes{piece_mesh(pieces=="a2",1)+1}.primitives=[obj.meshes{piece_mesh(pieces=="a2",1)+1}.primitives obj.meshes{piece_mesh(pieces=="b1",1)+1}.primitives(1)];
    obj.meshes{piece_mesh(pieces=="a2",1)+1}.primitives{3}.attributes.JOINTS_0=obj.addBinaryData(W(VN)*2,"UNSIGNED_SHORT","VEC4",true,"ARRAY_BUFFER");
    obj.meshes{piece_mesh(pieces=="a2",1)+1}.primitives=[obj.meshes{piece_mesh(pieces=="a2",1)+1}.primitives obj.meshes{piece_mesh(pieces=="c1",1)+1}.primitives(1)];
    obj.meshes{piece_mesh(pieces=="a2",1)+1}.primitives{4}.attributes.JOINTS_0=obj.addBinaryData(W(VB)*3,"UNSIGNED_SHORT","VEC4",true,"ARRAY_BUFFER");
    obj.meshes{piece_mesh(pieces=="a2",1)+1}.primitives=[obj.meshes{piece_mesh(pieces=="a2",1)+1}.primitives obj.meshes{piece_mesh(pieces=="a1",1)+1}.primitives(1)];
    obj.meshes{piece_mesh(pieces=="a2",1)+1}.primitives{5}.attributes.JOINTS_0=obj.addBinaryData(W(VC)*4,"UNSIGNED_SHORT","VEC4",true,"ARRAY_BUFFER");
    obj.meshes{piece_mesh(pieces=="a2",1)+1}.primitives=[obj.meshes{piece_mesh(pieces=="a2",1)+1}.primitives obj.meshes{piece_mesh(pieces=="d1",1)+1}.primitives(1)];
    obj.meshes{piece_mesh(pieces=="a2",1)+1}.primitives{6}.attributes.JOINTS_0=obj.addBinaryData(W(VQ)*5,"UNSIGNED_SHORT","VEC4",true,"ARRAY_BUFFER");
    % Duplicate pawn mesh for black piece.
    obj.meshes=obj.meshes([1:end end]);
    piece_mesh(pieces=="a2",2)=piece_mesh(pieces=="a2",1)+1;
    % Use black materials for black piece.
    obj.meshes{end}.primitives{1}.material=pawn_black_mat;
    obj.meshes{end}.primitives{2}.material=pawn_black_top_mat;
    obj.meshes{end}.primitives{3}.material=knight_black_mat;
    obj.meshes{end}.primitives{4}.material=bishop_black_mat;
    obj.meshes{end}.primitives{5}.material=castle_black_mat;
    obj.meshes{end}.primitives{6}.material=queen_black_mat;
    disp("Downloaded pawn textures.");

    % Place castle nodes at start positions.
    piece_node(positions=="a1")=obj.addNode('addToScene',false,'translation',[X(positions=="a1") 0 Z(positions=="a1")]);
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a1"==positions)),'skin',obj.addSkin(piece_node(positions=="a1"),'inverseBindMatrices',ibm),'children',piece_node(positions=="a1"));
    piece_node(positions=="h1")=obj.addNode('addToScene',false,'translation',[X(positions=="h1") 0 Z(positions=="h1")]);
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a1"==positions)),'skin',obj.addSkin(piece_node(positions=="h1"),'inverseBindMatrices',ibm),'children',piece_node(positions=="h1"));
    piece_node(positions=="a8")=obj.addNode('addToScene',false,'translation',[X(positions=="a8") 0 Z(positions=="a8")],'rotation',[0 1 0 0]);
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a8"==positions)),'skin',obj.addSkin(piece_node(positions=="a8"),'inverseBindMatrices',ibm),'children',piece_node(positions=="a8"));
    piece_node(positions=="h8")=obj.addNode('addToScene',false,'translation',[X(positions=="h8") 0 Z(positions=="h8")],'rotation',[0 1 0 0]);
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a8"==positions)),'skin',obj.addSkin(piece_node(positions=="h8"),'inverseBindMatrices',ibm),'children',piece_node(positions=="h8"));

    % Place knight nodes at start positions.
    piece_node(positions=="b1")=obj.addNode('addToScene',false,'translation',[X(positions=="b1") 0 Z(positions=="b1")]);
    obj.addNode('mesh',piece_mesh(pieces==position_piece("b1"==positions)),'skin',obj.addSkin(piece_node(positions=="b1"),'inverseBindMatrices',ibm),'children',piece_node(positions=="b1"));
    piece_node(positions=="g1")=obj.addNode('addToScene',false,'translation',[X(positions=="g1") 0 Z(positions=="g1")]);
    obj.addNode('mesh',piece_mesh(pieces==position_piece("b1"==positions)),'skin',obj.addSkin(piece_node(positions=="g1"),'inverseBindMatrices',ibm),'children',piece_node(positions=="g1"));
    piece_node(positions=="b8")=obj.addNode('addToScene',false,'translation',[X(positions=="b8") 0 Z(positions=="b8")],'rotation',[0 1 0 0]);
    obj.addNode('mesh',piece_mesh(pieces==position_piece("b8"==positions)),'skin',obj.addSkin(piece_node(positions=="b8"),'inverseBindMatrices',ibm),'children',piece_node(positions=="b8"));
    piece_node(positions=="g8")=obj.addNode('addToScene',false,'translation',[X(positions=="g8") 0 Z(positions=="g8")],'rotation',[0 1 0 0]);
    obj.addNode('mesh',piece_mesh(pieces==position_piece("b8"==positions)),'skin',obj.addSkin(piece_node(positions=="g8"),'inverseBindMatrices',ibm),'children',piece_node(positions=="g8"));

    % Place bishop nodes at start positions.
    piece_node(positions=="c1")=obj.addNode('addToScene',false,'translation',[X(positions=="c1") 0 Z(positions=="c1")]);
    obj.addNode('mesh',piece_mesh(pieces==position_piece("c1"==positions)),'skin',obj.addSkin(piece_node(positions=="c1"),'inverseBindMatrices',ibm),'children',piece_node(positions=="c1"));
    piece_node(positions=="f1")=obj.addNode('addToScene',false,'translation',[X(positions=="f1") 0 Z(positions=="f1")]);
    obj.addNode('mesh',piece_mesh(pieces==position_piece("c1"==positions)),'skin',obj.addSkin(piece_node(positions=="f1"),'inverseBindMatrices',ibm),'children',piece_node(positions=="f1"));
    piece_node(positions=="c8")=obj.addNode('addToScene',false,'translation',[X(positions=="c8") 0 Z(positions=="c8")],'rotation',[0 1 0 0]);
    obj.addNode('mesh',piece_mesh(pieces==position_piece("c8"==positions)),'skin',obj.addSkin(piece_node(positions=="c8"),'inverseBindMatrices',ibm),'children',piece_node(positions=="c8"));
    piece_node(positions=="f8")=obj.addNode('addToScene',false,'translation',[X(positions=="f8") 0 Z(positions=="f8")],'rotation',[0 1 0 0]);
    obj.addNode('mesh',piece_mesh(pieces==position_piece("c8"==positions)),'skin',obj.addSkin(piece_node(positions=="f8"),'inverseBindMatrices',ibm),'children',piece_node(positions=="f8"));

    % Place castle nodes at start positions.
    piece_node(positions=="d1")=obj.addNode('addToScene',false,'translation',[X(positions=="d1") 0 Z(positions=="d1")]);
    obj.addNode('mesh',piece_mesh(pieces==position_piece("d1"==positions)),'skin',obj.addSkin(piece_node(positions=="d1"),'inverseBindMatrices',ibm),'children',piece_node(positions=="d1"));
    piece_node(positions=="d8")=obj.addNode('addToScene',false,'translation',[X(positions=="d8") 0 Z(positions=="d8")],'rotation',[0 1 0 0]);
    obj.addNode('mesh',piece_mesh(pieces==position_piece("d8"==positions)),'skin',obj.addSkin(piece_node(positions=="d8"),'inverseBindMatrices',ibm),'children',piece_node(positions=="d8"));

    % Place king nodes at start positions, but account for extra rotation
    % nodes for resignation animation.
    basenode=obj.addNode('addToScene',false,'translation',-rebase);
    piecerotation=obj.addNode('addToScene',false,'children',basenode,'translation',rebase);
    piece_node(positions=="e1")=obj.addNode('addToScene',false,'children',piecerotation,'translation',[X(positions=="e1") 0 Z(positions=="e1")]);
    ibm2=[eye(3) -rebase';zeros(1,3) 1];
    ibmfull=cat(3,ibm,ibm2,ibm);
    obj.addNode('mesh',piece_mesh(pieces==position_piece("e1"==positions)),'skin',obj.addSkin([piece_node(positions=="e1") piecerotation basenode],'inverseBindMatrices',ibmfull),'children',piece_node(positions=="e1"));
    basenode=obj.addNode('addToScene',false,'translation',-rebase,'rotation',[0 1 0 0]);
    piecerotation=obj.addNode('addToScene',false,'children',basenode,'translation',rebase);
    piece_node(positions=="e8")=obj.addNode('addToScene',false,'children',piecerotation,'translation',[X(positions=="e8") 0 Z(positions=="e8")]);
    obj.addNode('mesh',piece_mesh(pieces==position_piece("e8"==positions)),'skin',obj.addSkin([piece_node(positions=="e1") piecerotation basenode],'inverseBindMatrices',ibmfull),'children',piece_node(positions=="e8"));

    promotion_nodes=table('Size',[16 6],'VariableTypes',{'uint16','uint16','uint16','uint16','uint16','uint16'},'VariableNames',{'base','P','N','B','R','Q'});
    % Place pawn nodes at start positions.
    for i=1:16
        promotion_nodes{i,2}=obj.addNode('addToScene',false,'scale',ones(1,3));
        for j=2:5
            promotion_nodes{i,j+1}=obj.addNode('addToScene',false,'scale',zeros(1,3));
        end
    end
    ibm3=repmat(ibm,1,1,6);
    piece_node(positions=="a2")=obj.addNode('addToScene',false,'translation',[X(positions=="a2") 0 Z(positions=="a2")],'children',promotion_nodes{1,2:6});
    promotion_nodes{1,1}=piece_node(positions=="a2");
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a2"==positions)),'skin',obj.addSkin([piece_node(positions=="a2") promotion_nodes{1,2:6}],'inverseBindMatrices',ibm3),'children',piece_node(positions=="a2"));
    piece_node(positions=="b2")=obj.addNode('addToScene',false,'translation',[X(positions=="b2") 0 Z(positions=="b2")],'children',promotion_nodes{2,2:6});
    promotion_nodes{2,1}=piece_node(positions=="b2");
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a2"==positions)),'skin',obj.addSkin([piece_node(positions=="b2") promotion_nodes{2,2:6}],'inverseBindMatrices',ibm3),'children',piece_node(positions=="b2"));
    piece_node(positions=="c2")=obj.addNode('addToScene',false,'translation',[X(positions=="c2") 0 Z(positions=="c2")],'children',promotion_nodes{3,2:6});
    promotion_nodes{3,1}=piece_node(positions=="c2");
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a2"==positions)),'skin',obj.addSkin([piece_node(positions=="c2") promotion_nodes{3,2:6}],'inverseBindMatrices',ibm3),'children',piece_node(positions=="c2"));
    piece_node(positions=="d2")=obj.addNode('addToScene',false,'translation',[X(positions=="d2") 0 Z(positions=="d2")],'children',promotion_nodes{4,2:6});
    promotion_nodes{4,1}=piece_node(positions=="d2");
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a2"==positions)),'skin',obj.addSkin([piece_node(positions=="d2") promotion_nodes{4,2:6}],'inverseBindMatrices',ibm3),'children',piece_node(positions=="d2"));
    piece_node(positions=="e2")=obj.addNode('addToScene',false,'translation',[X(positions=="e2") 0 Z(positions=="e2")],'children',promotion_nodes{5,2:6});
    promotion_nodes{5,1}=piece_node(positions=="e2");
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a2"==positions)),'skin',obj.addSkin([piece_node(positions=="e2") promotion_nodes{5,2:6}],'inverseBindMatrices',ibm3),'children',piece_node(positions=="e2"));
    piece_node(positions=="f2")=obj.addNode('addToScene',false,'translation',[X(positions=="f2") 0 Z(positions=="f2")],'children',promotion_nodes{6,2:6});
    promotion_nodes{6,1}=piece_node(positions=="f2");
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a2"==positions)),'skin',obj.addSkin([piece_node(positions=="f2") promotion_nodes{6,2:6}],'inverseBindMatrices',ibm3),'children',piece_node(positions=="f2"));
    piece_node(positions=="g2")=obj.addNode('addToScene',false,'translation',[X(positions=="g2") 0 Z(positions=="g2")],'children',promotion_nodes{7,2:6});
    promotion_nodes{7,1}=piece_node(positions=="g2");
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a2"==positions)),'skin',obj.addSkin([piece_node(positions=="g2") promotion_nodes{7,2:6}],'inverseBindMatrices',ibm3),'children',piece_node(positions=="g2"));
    piece_node(positions=="h2")=obj.addNode('addToScene',false,'translation',[X(positions=="h2") 0 Z(positions=="h2")],'children',promotion_nodes{8,2:6});
    promotion_nodes{8,1}=piece_node(positions=="h2");
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a2"==positions)),'skin',obj.addSkin([piece_node(positions=="h2") promotion_nodes{8,2:6}],'inverseBindMatrices',ibm3),'children',piece_node(positions=="h2"));
    piece_node(positions=="a7")=obj.addNode('addToScene',false,'translation',[X(positions=="a7") 0 Z(positions=="a7")],'rotation',[0 1 0 0],'children',promotion_nodes{9,2:6});
    promotion_nodes{9,1}=piece_node(positions=="a7");
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a7"==positions)),'skin',obj.addSkin([piece_node(positions=="a7") promotion_nodes{9,2:6}],'inverseBindMatrices',ibm3),'children',piece_node(positions=="a7"));
    piece_node(positions=="b7")=obj.addNode('addToScene',false,'translation',[X(positions=="b7") 0 Z(positions=="b7")],'rotation',[0 1 0 0],'children',promotion_nodes{10,2:6});
    promotion_nodes{10,1}=piece_node(positions=="b7");
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a7"==positions)),'skin',obj.addSkin([piece_node(positions=="b7") promotion_nodes{10,2:6}],'inverseBindMatrices',ibm3),'children',piece_node(positions=="b7"));
    piece_node(positions=="c7")=obj.addNode('addToScene',false,'translation',[X(positions=="c7") 0 Z(positions=="c7")],'rotation',[0 1 0 0],'children',promotion_nodes{11,2:6});
    promotion_nodes{11,1}=piece_node(positions=="c7");
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a7"==positions)),'skin',obj.addSkin([piece_node(positions=="c7") promotion_nodes{11,2:6}],'inverseBindMatrices',ibm3),'children',piece_node(positions=="c7"));
    piece_node(positions=="d7")=obj.addNode('addToScene',false,'translation',[X(positions=="d7") 0 Z(positions=="d7")],'rotation',[0 1 0 0],'children',promotion_nodes{12,2:6});
    promotion_nodes{12,1}=piece_node(positions=="d7");
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a7"==positions)),'skin',obj.addSkin([piece_node(positions=="d7") promotion_nodes{12,2:6}],'inverseBindMatrices',ibm3),'children',piece_node(positions=="d7"));
    piece_node(positions=="e7")=obj.addNode('addToScene',false,'translation',[X(positions=="e7") 0 Z(positions=="e7")],'rotation',[0 1 0 0],'children',promotion_nodes{13,2:6});
    promotion_nodes{13,1}=piece_node(positions=="e7");
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a7"==positions)),'skin',obj.addSkin([piece_node(positions=="e7") promotion_nodes{13,2:6}],'inverseBindMatrices',ibm3),'children',piece_node(positions=="e7"));
    piece_node(positions=="f7")=obj.addNode('addToScene',false,'translation',[X(positions=="f7") 0 Z(positions=="f7")],'rotation',[0 1 0 0],'children',promotion_nodes{14,2:6});
    promotion_nodes{14,1}=piece_node(positions=="f7");
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a7"==positions)),'skin',obj.addSkin([piece_node(positions=="f7") promotion_nodes{14,2:6}],'inverseBindMatrices',ibm3),'children',piece_node(positions=="f7"));
    piece_node(positions=="g7")=obj.addNode('addToScene',false,'translation',[X(positions=="g7") 0 Z(positions=="g7")],'rotation',[0 1 0 0],'children',promotion_nodes{15,2:6});
    promotion_nodes{15,1}=piece_node(positions=="g7");
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a7"==positions)),'skin',obj.addSkin([piece_node(positions=="g7") promotion_nodes{15,2:6}],'inverseBindMatrices',ibm3),'children',piece_node(positions=="g7"));
    piece_node(positions=="h7")=obj.addNode('addToScene',false,'translation',[X(positions=="h7") 0 Z(positions=="h7")],'rotation',[0 1 0 0],'children',promotion_nodes{16,2:6});
    promotion_nodes{16,1}=piece_node(positions=="h7");
    obj.addNode('mesh',piece_mesh(pieces==position_piece("a7"==positions)),'skin',obj.addSkin([piece_node(positions=="h7") promotion_nodes{16,2:6}],'inverseBindMatrices',ibm3),'children',piece_node(positions=="h7"));
end

function chess=addChessAnimation(chess,piece_node,promotion_nodes,filename,varargin)
    ips=inputParser;
    ips.addParameter('start_T',0,@isnumeric);
    ips.addParameter('name',missing,@isstring);
    ips.parse(varargin{:});
    parameters=ips.Results;
    start_T=parameters.start_T;
    name=parameters.name;

    [game,promotions,outcome]=readPGN(filename);
    
    % Generate times
    seconds=sum(~ismissing(game(:,1:2:end)),2);
    % Correct times for castling moves.
    castles=[
        "E1"    "g1"    "H1"    "f1";
        "E1"    "c1"    "A1"    "d1";
        "E8"    "g8"    "H8"    "f8";
        "E8"    "c8"    "A8"    "d8";
        ];
    seconds=seconds-ismember(game(:,1:4),castles,'rows');
    seconds=seconds+(~ismissing(promotions));
    
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
    tstart=[tstart strlength(promotions)-strlength(promotions)+max(tend,[],2)];
    tend=[tend strlength(promotions)+max(tend,[],2)];

    if(start_T<0)
        start_T=max(tend,[],'all')+start_T;
    end

    if(ismember(outcome,["1-0","0-1"]))
        % Wait 3 seconds after game ends for resignation animation.
        maxt=max(tend,[],'all')+3;
    else
        maxt=max(tend,[],'all');
    end
    % Pieces and positions names
    pieces=upper(string(num2cell(char(97:104)))+string([1 2 7 8]'));
    positions=string(num2cell(char([119:122 97:108])))+string(1:8)';
    
    % Positions including off-the-board ones for taken pieces.
    [X,Z]=meshgrid([-9.5:-6.5 -3.5:3.5 6.5:9.5],3.5:-1:-3.5);
    X=X/16;
    Z=Z/16;
    % Off-the-board positions should be on the table level.
    temp=chess.getAccessor(chess.meshes{1}.primitives{1}.attributes.POSITION);
    Y=zeros(size(positions));
    Y(:,[1:4 13:16])=min(temp(:,2));
    t=cell(numel(pieces),1);
    x=cell(numel(pieces),1);
    % For each piece;
    for piece=pieces(:)'
        % Get the node.
        node_idx=piece_node(pieces==piece)+1;
        % Get start position.
        x0=chess.nodes{node_idx}.translation;
        % Get all the moves of the piece.
        [Move,T]=find(contains(game,piece)');
        % If the piece is moved at all;
        if(numel(T)>0)
            t{piece==pieces(:)'}=nan(1,2*numel(T));
            x{piece==pieces(:)'}=nan(2*numel(T),3);
            % Each time it is moved;
            for i=1:numel(T)
                % Get start and end times of the move.
                t{piece==pieces(:)'}(2*i-1)=tstart(T(i),(Move(i)+1)/2);
                t{piece==pieces(:)'}(2*i)=tend(T(i),(Move(i)+1)/2);
                % If it's the first move of the piece;
                if(i==1)
                    % Move starts from start position.
                    x{piece==pieces(:)'}(2*i-1,:)=x0;
                else
                    % Else move starts from last position.
                    x{piece==pieces(:)'}(2*i-1,:)=x{piece==pieces(:)'}(2*i-2,:);
                end
                % Get end position of move.
                position=game(T(i),Move(i)+1);
                % Move ends in end position
                x{piece==pieces(:)'}(2*i,:)=[X(positions==position) Y(positions==position) Z(positions==position)];
            end
            % Stay in final position for 3 seconds for resignation animation.
            t{piece==pieces(:)'}=[t{piece==pieces(:)'} maxt];
            x{piece==pieces(:)'}=x{piece==pieces(:)'}([1:end end],:);
        end
    end
    
    for i=1:numel(pieces(:))
        if(~isempty(t{i}))
            tempT=find(t{i}<=start_T,1,'last');
            if(isempty(tempT))
                tempT=1;
            end
            x{i}=x{i}(tempT:end,:);
            t{i}=max(t{i}(tempT:end),start_T)-start_T;
        end
    end
    
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
    
    for piece=pieces(:)'
        promt=and(contains(game(:,1),piece),~ismissing(promotions));
        if(any(promt))
            node_idx=piece_node(pieces==piece);
            prom=promotions(promt);
            tp=[tstart(promt,3) tend(promt,3)];
            tp=max(tp,start_T)-start_T;
            if(all(tp==0))
                tp(2)=tp(2)+double(eps('single'));
            end
            out1=[0 0 0;1 1 1];
            out2=[1 1 1;0 0 0];
            samplers=[samplers chess.addAnimationSampler(chess.addBinaryData(tp,"FLOAT","SCALAR",true),chess.addBinaryData(out1,"FLOAT","VEC3",true)) chess.addAnimationSampler(chess.addBinaryData(tp,"FLOAT","SCALAR",true),chess.addBinaryData(out2,"FLOAT","VEC3",true))]; %#ok<AGROW>
            channels=[channels chess.addAnimationChannel(sampler_count,promotion_nodes{promotion_nodes.base==node_idx,prom},"scale") chess.addAnimationChannel(sampler_count+1,promotion_nodes{promotion_nodes.base==node_idx,"P"},"scale")]; %#ok<AGROW>
            sampler_count=sampler_count+2;
        end
    end
    
    if(outcome=="1-0")
        % Get node of resignation king.
        node_idx=chess.nodes{piece_node(pieces=="E8")+1}.children{1};
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
    elseif(outcome=="0-1")
        % Get node of resignation king.
        node_idx=chess.nodes{piece_node(pieces=="E1")+1}.children{1};
        % Get the times for resignation animation.
        t=max(tend,[],'all')+(1:3);
        t=t-start_T;
        % Upon resignation, the king falls 90° on its side, so create rotation
        % quaternions.
        q=[0 0 0 1;0 0 1/sqrt(2) 1/sqrt(2);0 0 1/sqrt(2) 1/sqrt(2)];
        
        % Add time and rotation sampler.
        samplers=[samplers chess.addAnimationSampler(chess.addBinaryData(t,"FLOAT","SCALAR",true),chess.addBinaryData(q,"FLOAT","VEC4",true))];
        % Set the animation channel to node rotation.
        channels=[channels chess.addAnimationChannel(sampler_count,node_idx,"rotation")];
    end
    
    % Add the animation.
    chess.addAnimation(samplers,channels,'name',name);
end

function [game,promotions,outcome]=readPGN(filename)
    pgn=string(fileread(filename));
    while(contains(pgn,"["))
        pgn=replaceBetween(pgn,regexp(pgn,"\[","once"),regexp(pgn,"\]","once"),"","Boundaries","inclusive");
    end
    while(contains(pgn,"{"))
        pgn=replaceBetween(pgn,regexp(pgn,"\{","once"),regexp(pgn,"\}","once"),"","Boundaries","inclusive");
    end
    bites=regexp(pgn,"[^\s{}\.]+|{[^{}]*}",'match');
    bites=bites(isnan(str2double(bites)));
    outcomes=["1-0","0-1","1/2-1/2"];
    if (~isempty(bites) && ismember(bites(end),outcomes))
        outcome=bites(end);
        bites=bites(1:end-1);
    else
        outcome="";
    end
    moves_pattern="([NBRQK]?[a-h]?[1-8]?[xX\-]?[a-h][1-8](=[NBRQ]|\s?e\s?\.p\.)?|(?:O\-O(?:\-O)?))([+#])?";
    out=regexp(bites,moves_pattern,"tokens");
    moves=string(cellfun(@(x)x{1}{1},out,'UniformOutput',false)');
    just_board=[upper(string(num2cell(char(97:104)))+string([8 7]'));strings(4,8);upper(string(num2cell(char(97:104)))+string([2 1]'))];
    board=[[strings(4,4);repmat(missing,4,4)] just_board [repmat(missing,4,4);strings(4,4)]];
    board(2,5:12)=board(2,5:12)+"P";
    board(7,5:12)=board(7,5:12)+"P";
    turns=moves;
    turns(1:2:end)="w";
    turns(2:2:end)="b";
    game=repmat(string(missing),numel(moves),4);
    promotions=repmat(string(missing),numel(moves),1);
    for i=1:numel(moves)
        move=moves(i);
        turn=turns(i);
        [piece,to,promotion,board]=decodeMove(move,turn,board);
        temp=reshape([piece';to'],1,[]);
        game(i,1:numel(temp))=temp;
        promotions(i)=promotion;
    end
end

function [piece,to,promotion,board]=decodeMove(move,turn,board)
    ranks=string(8:-1:1)';
    files=string(char([118+(1:4) 96+(1:12)])')';
    positions=files+ranks;
    if(turn=="w")
        discard_pile=reshape(board(8:-1:5,13:16),[],1);
        discard_pile_locs=reshape(positions(8:-1:5,13:16),[],1);
        next_discard=discard_pile_locs(find(discard_pile=="",1));
    elseif(turn=="b")
        discard_pile=reshape(board(1:4,4:-1:1),[],1);
        discard_pile_locs=reshape(positions(1:4,4:-1:1),[],1);
        next_discard=discard_pile_locs(find(discard_pile=="",1));
    end
    if(move=="O-O") % Kingside Castling
        if(turn=="w")
            piece=["E1";"H1"];
            to=["g1";"f1"];
            promotion=missing;
            board(ranks=="1",files=="g")="E1";
            board(ranks=="1",files=="f")="H1";
            board(ranks=="1",files=="e")="";
            board(ranks=="1",files=="h")="";
        elseif(turn=="b")
            piece=["E8";"H8"];
            to=["g8";"f8"];
            promotion=missing;
            board(ranks=="8",files=="g")="E8";
            board(ranks=="8",files=="f")="H8";
            board(ranks=="8",files=="e")="";
            board(ranks=="8",files=="h")="";
        end
    elseif(move=="O-O-O") % Queenside Castling
        if(turn=="w")
            piece=["E1";"A1"];
            to=["c1";"d1"];
            promotion=missing;
            board(ranks=="1",files=="c")="E1";
            board(ranks=="1",files=="d")="A1";
            board(ranks=="1",files=="e")="";
            board(ranks=="1",files=="a")="";
        elseif(turn=="b")
            piece=["E8";"A8"];
            to=["c8";"d8"];
            promotion=missing;
            board(ranks=="8",files=="c")="E8";
            board(ranks=="8",files=="d")="A8";
            board(ranks=="8",files=="e")="";
            board(ranks=="8",files=="a")="";
        end
    else
        if(isempty(regexp(move,"=[NBRQ]","once"))) % Promotion
            promotion=missing;
        else
            promotion=cellfun(@(x)x(1),regexp(move,"=([NBRQ])","tokens"));
            move=extractBefore(move,regexp(move,"=[NBRQ]","once"));
        end
        to=extractAfter(move,strlength(move)-2);
        move=extractBefore(move,strlength(move)-1);
        capture=contains(move,"x");
        if(capture) % Capture
            if(board(positions==to)=="") % En passant
                if(turn=="w")
                    enpassant=string(char(char(to)-[1 0]));
                elseif(turn=="b")
                    enpassant=string(char(char(to)+[1 0]));
                end
                captured_piece=board(positions==enpassant);
            else
                captured_piece=board(positions==to);
            end
            piece=captured_piece;
            to=[to;next_discard];
            move=extractBefore(move,strlength(move));
            board(board==captured_piece)="";
            board(positions==next_discard)=captured_piece;
        else
            piece=[];
        end
        piece_origin_pattern="([NBRQK])?([a-h])?([1-8])?";
        out=regexp(move,piece_origin_pattern,"tokens");
        if(isempty(out))
            movedpiece="";
            from_file="";
            from_rank="";
        else
            out=out{1};
            movedpiece=out(1);
            from_file=out(2);
            from_rank=out(3);
        end
        possibilities1=and(~cellfun(@isempty,regexp(positions,"[a-h]")),and(contains(positions,from_file),contains(positions,from_rank)));
        switch(movedpiece)
            case "K"
                if(turn=="w")
                    piece=["E1";piece];
                elseif(turn=="b")
                    piece=["E8";piece];
                end
            case "Q"
                [I,J]=find(positions==to(1));
                possibilities2=false(8,16);
                for i=I-1:-1:1
                    possibilities2(i,J)=true;
                    if(board(i,J)~="")
                        break;
                    end
                end
                for i=I+1:8
                    possibilities2(i,J)=true;
                    if(board(i,J)~="")
                        break;
                    end
                end
                for j=J-1:-1:5
                    possibilities2(I,j)=true;
                    if(board(I,j)~="")
                        break;
                    end
                end
                for j=J+1:12
                    possibilities2(I,j)=true;
                    if(board(I,j)~="")
                        break;
                    end
                end
                for k=1:min(I-1,max(J-5,0))
                    possibilities2(I-k,J-k)=true;
                    if(board(I-k,J-k)~="")
                        break;
                    end
                end
                for k=1:min(8-I,max(J-5,0))
                    possibilities2(I+k,J-k)=true;
                    if(board(I+k,J-k)~="")
                        break;
                    end
                end
                for k=1:min(I-1,max(12-J,0))
                    possibilities2(I-k,J+k)=true;
                    if(board(I-k,J+k)~="")
                        break;
                    end
                end
                for k=1:min(8-I,max(12-J,0))
                    possibilities2(I+k,J+k)=true;
                    if(board(I+k,J+k)~="")
                        break;
                    end
                end
                if(turn=="w")
                    possibilities3=or(board=="D1",matches(board,characterListPattern("ABCDEFGH")+characterListPattern("2")+characterListPattern("Q")));
                elseif(turn=="b")
                    possibilities3=or(board=="D8",matches(board,characterListPattern("ABCDEFGH")+characterListPattern("7")+characterListPattern("Q")));
                end
                possibilities=and(and(possibilities1,possibilities2),possibilities3);
                piece=[board(possibilities);piece];
            case "R"
                possibilities2=false(8,16);
                [I,J]=find(positions==to(1));
                for i=I-1:-1:1
                    possibilities2(i,J)=true;
                    if(board(i,J)~="")
                        break;
                    end
                end
                for i=I+1:8
                    possibilities2(i,J)=true;
                    if(board(i,J)~="")
                        break;
                    end
                end
                for j=J-1:-1:5
                    possibilities2(I,j)=true;
                    if(board(I,j)~="")
                        break;
                    end
                end
                for j=J+1:12
                    possibilities2(I,j)=true;
                    if(board(I,j)~="")
                        break;
                    end
                end
                if(turn=="w")
                    possibilities3=or(ismember(board,["A1","H1"]),matches(board,characterListPattern("ABCDEFGH")+characterListPattern("2")+characterListPattern("R")));
                elseif(turn=="b")
                    possibilities3=or(ismember(board,["A8","H8"]),matches(board,characterListPattern("ABCDEFGH")+characterListPattern("7")+characterListPattern("R")));
                end
                possibilities=and(and(possibilities1,possibilities2),possibilities3);
                piece=[board(possibilities);piece];
            case "B"
                [I,J]=find(positions==to(1));
                possibilities2=false(8,16);
                for k=1:min(I-1,max(J-5,0))
                    possibilities2(I-k,J-k)=true;
                    if(board(I-k,J-k)~="")
                        break;
                    end
                end
                for k=1:min(8-I,max(J-5,0))
                    possibilities2(I+k,J-k)=true;
                    if(board(I+k,J-k)~="")
                        break;
                    end
                end
                for k=1:min(I-1,max(12-J,0))
                    possibilities2(I-k,J+k)=true;
                    if(board(I-k,J+k)~="")
                        break;
                    end
                end
                for k=1:min(8-I,max(12-J,0))
                    possibilities2(I+k,J+k)=true;
                    if(board(I+k,J+k)~="")
                        break;
                    end
                end
                if(turn=="w")
                    possibilities3=or(ismember(board,["C1","F1"]),matches(board,characterListPattern("ABCDEFGH")+characterListPattern("2")+characterListPattern("B")));
                elseif(turn=="b")
                    possibilities3=or(ismember(board,["C8","F8"]),matches(board,characterListPattern("ABCDEFGH")+characterListPattern("7")+characterListPattern("B")));
                end
                possibilities=and(and(possibilities1,possibilities2),possibilities3);
                piece=[board(possibilities);piece];
            case "N"
                [I,J]=meshgrid(-2:2);
                origin_pat=I.^2+J.^2==5;
                possibilities2=conv2(positions==to(1),origin_pat,"same")>0;
                if(turn=="w")
                    possibilities3=or(ismember(board,["B1","G1"]),matches(board,characterListPattern("ABCDEFGH")+characterListPattern("2")+characterListPattern("N")));
                elseif(turn=="b")
                    possibilities3=or(ismember(board,["B8","G8"]),matches(board,characterListPattern("ABCDEFGH")+characterListPattern("7")+characterListPattern("N")));
                end
                possibilities=and(and(possibilities1,possibilities2),possibilities3);
                piece=[board(possibilities);piece];
            case ""
                if(turn=="w")
                    if(capture)
                        origin_pat=[0 0 0;0 0 0;1 0 1]>0;
                    else
                        origin_pat=[0 0 0;0 0 0;0 1 0]>0;
                        [I,J]=find(positions==to(1));
                        if(and(and(turn=="w",I==5),board(6,J)==""))
                            origin_pat=[0 0 0;0 0 0;0 0 0;0 1 0;0 1 0]>0;
                        end
                    end
                    possibilities3=contains(board,"2P");
                elseif(turn=="b")
                    if(capture)
                        origin_pat=[1 0 1;0 0 0;0 0 0]>0;
                    else
                        origin_pat=[0 1 0;0 0 0;0 0 0]>0;
                        [I,J]=find(positions==to(1));
                        if(and(and(turn=="b",I==4),board(3,J)==""))
                            origin_pat=[0 1 0;0 1 0;0 0 0;0 0 0;0 0 0]>0;
                        end
                    end
                    possibilities3=contains(board,"7P");
                end
                possibilities2=conv2(positions==to(1),origin_pat,"same")>0;
                possibilities=and(and(possibilities1,possibilities2),possibilities3);
                piece=[board(possibilities);piece];
        end
        board(board==piece(1))="";
        if(~ismissing(promotion))
            piece(1)=extractBefore(piece(1),3)+promotion;
        end
        board(positions==to(1))=piece(1);
    end
end
