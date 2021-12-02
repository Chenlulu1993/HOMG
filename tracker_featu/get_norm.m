function I_norm = get_norm(I)
c = sign(I);
I1 = abs(I);
FlattenedData = I1(:)'; % ¡£
MappedFlattened = mapminmax(FlattenedData, 0, 1);
I_norm = reshape(MappedFlattened, size(I)).*c;

end