*************
Config Params
*************

FeatureFinderIdentification (process: find_features)
####################################################

See `here <https://abibuilder.informatik.uni-tuebingen.de/archive/openms/Documentation/nightly/html/TOPP_FeatureFinderIdentification.html>`_ for OpenMS's documentation of FeatureFinderIdentification.

{% with data=data['find_features'] %}
{% include "_table.rst" %}
{% endwith %}

MapAlignerIdentification (process: align_featureXML)
####################################################

See `here <https://abibuilder.informatik.uni-tuebingen.de/archive/openms/Documentation/nightly/html/TOPP_MapAlignerIdentification.html>`_ for OpenMS's documentation of MapAlignerIdentification.

{% with data=data['align_featureXML'] %}
{% include "_table.rst" %}
{% endwith %}

MapAlignerIdentification (process: align_idXML)
###############################################

See `here <https://abibuilder.informatik.uni-tuebingen.de/archive/openms/Documentation/nightly/html/TOPP_MapAlignerIdentification.html>`_ for OpenMS's documentation of MapAlignerIdentification.

{% with data=data['align_idXML'] %}
{% include "_table.rst" %}
{% endwith %}

MapRTTransformer (process: transform_rt)
########################################

See `here <https://abibuilder.informatik.uni-tuebingen.de/archive/openms/Documentation/nightly/html/TOPP_MapRTTransformer.html>`_ for OpenMS's documentation of MapRTTransformer.

{% with data=data['transform_rt'] %}
{% include "_table.rst" %}
{% endwith %}

FeatureLinkerUnlabeledQT (process: link_features)
#################################################

See `here <https://abibuilder.informatik.uni-tuebingen.de/archive/openms/Documentation/nightly/html/TOPP_FeatureLinkerUnlabeledQT.html>`_ for OpenMS's documentation of FeatureLinkerUnlabeledQT.

{% with data=data['link_features'] %}
{% include "_table.rst" %}
{% endwith %}

IDConflictResolver (process: resolve_conflict)
##############################################

See `here <https://abibuilder.informatik.uni-tuebingen.de/archive/openms/Documentation/nightly/html/TOPP_IDConflictResolver.html>`_ for OpenMS's documentation of IDConflictResolver.

{% with data=data['resolve_conflict'] %}
{% include "_table.rst" %}
{% endwith %}

ProteinQuantifier (process: quantify_peptides)
##############################################

See `here <https://abibuilder.informatik.uni-tuebingen.de/archive/openms/Documentation/nightly/html/TOPP_ProteinQuantifier.html>`_ for OpenMS's documentation of ProteinQuantifier.

{% with data=data['quantify_peptides'] %}
{% include "_table.rst" %}
{% endwith %}
