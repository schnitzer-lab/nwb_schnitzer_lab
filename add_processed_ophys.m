function nwb = add_processed_ophys(nwb, metadata, image_masks, ...
    roi_response_data, frame_times)

if ~ exist('frame_times','var') || isempty(frame_times)
    frame_times = [];
end
    
n_rois = size(image_masks, 1);

op_input_args = get_input_args(metadata, 'OpticalChannel');
optical_channel = types.core.OpticalChannel(op_input_args{:});

device = nwb.general_devices.set(metadata.device_name, types.core.Device());

ip_input_args = get_input_args(metadata, 'ImagingPlane');
imaging_plane = types.core.ImagingPlane('device', ...
    types.untyped.SoftLink(['/general/devices/' metadata.device_name]), ...
    ip_input_args{:});

nwb.general_optophysiology.set(metadata.imaging_plane_name, imaging_plane);

imaging_plane_path = ['/general/optophysiology/' metadata.imaging_plane_name];

ophys_module = types.core.ProcessingModule(...
    'description', 'holds processed calcium imaging data');

ps_input_args = get_input_args(metadata, 'PlaneSegmentation');
plane_segmentation = types.core.PlaneSegmentation( ...
    'imaging_plane', imaging_plane, ...
    'colnames', {'imaging_mask'}, ...
    'id', types.core.ElementIdentifiers('data', int64(0:n_rois-1)), ...
    ps_input_args{:});

plane_segmentation.image_mask = types.core.VectorData( ...
    'data', image_masks, 'description', 'image masks');

img_seg = types.core.ImageSegmentation();
img_seg.planesegmentation.set('PlaneSegmentation', plane_segmentation);

ophys_module.nwbdatainterface.set('ImageSegmentation', img_seg);
nwb.processing.set('ophys', ophys_module);

plane_seg_object_view = types.untyped.ObjectView( ...
    '/processing/ophys/ImageSegmentation/PlaneSegmentation');

roi_table_region = types.core.DynamicTableRegion( ...
    'table', plane_seg_object_view, ...
    'description', 'all_rois', ...
    'data', [0 n_rois-1]');

roi_response_series_varargin = get_input_args(metadata, 'RoiResponseSeries');

if frame_times
    roi_response_series = types.core.RoiResponseSeries( ...
    'rois', roi_table_region, ...
    'data', roi_response_data, ...
    'data_unit', 'lumens', ...
    'timestamps', frame_times, ...
    roi_response_series_varargin{:});
else
    roi_response_series = types.core.RoiResponseSeries( ...
    'rois', roi_table_region, ...
    'data', roi_response_data, ...
    'data_unit', 'lumens', ...
    'starting_time_rate', metadata.imaging_rate, ...
    roi_response_series_varargin{:});

end

fluorescence = types.core.Fluorescence();
fluorescence.roiresponseseries.set('RoiResponseSeries', roi_response_series);

ophys_module.nwbdatainterface.set('Fluorescence', fluorescence);

nwb.processing.set('ophys', ophys_module);







end