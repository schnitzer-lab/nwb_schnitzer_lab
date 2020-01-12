function [image_masks, roi_response_data] = extract_nwb_data_cnmfe(fpath,data_type)

dat = load(fpath);
if strcmp(data_type,'cnmfe')
    image_masks = dat.cnmfeAnalysisOutput.extractedImages;
    
    data_fields=fields(dat.cnmfeAnalysisOutput);
    MatchedFields=cellfun(@(x) contains(x,'extractedSignals'), data_fields);
    touse=data_fields(MatchedFields);
    
    for i=1: length(touse)
        roi_response_data.(['ROI_' num2str(i)]) = dat.cnmfeAnalysisOutput.(touse{i});
    end
    
elseif strcmp(data_type,'extract')
elseif strcmp(data_type,'cnmf')
elseif strcmp(data_type,'em')
    
end

end