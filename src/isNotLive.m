function inl = isNotLive()
ds = dbstack();
callStack = {ds.file};

if length(callStack)<2 % not command prompt
    inl = false;
else % neither cell mode nor live editor
    inl = ~any(startsWith(callStack, 'LiveEditor'));
end

