from collections import defaultdict

from docutils.parsers.rst import directives

from sphinx import addnodes
from sphinx.application import Sphinx
from sphinx.directives import ObjectDescription
from sphinx.domains import Domain, Index
from sphinx.roles import XRefRole
from sphinx.util.nodes import make_refnode
from docutils import nodes
from sphinx.util.docfields import TypedField, GroupedField

class CallSeqField(GroupedField):
    def __init__(self):
        super().__init__('callseq', ('callseq',), 'Calling sequence')

    def make_entry(self, field_arg, content):
        call = content[0].astext()
        literal = nodes.literal_block(call, call)
        literal['language'] = field_arg
        container_node = nodes.container('', literal_block=True,
                classes=['callseq-block-wrapper'])
        container_node += nodes.caption(field_arg, 'From '+field_arg)
        container_node += literal
        return field_arg, container_node

    def make_field(self, types, domain, items, env, inliner, location):
        fieldname = nodes.field_name('', self.label)
        listnode = nodes.container(classes=['callseq-field'])
        for fieldarg, content in items:
            listnode += content
        fieldbody = nodes.field_body('', listnode)
        return nodes.field('', fieldname, fieldbody, )

class RoutineDirective(ObjectDescription):
    """A custom directive that describes a subroutine."""

    has_content = True
    required_arguments = 1
    option_spec = {
        'contains': directives.unchanged_required,
    }
    doc_field_types = [
        CallSeqField(),
        TypedField('parameters', label='Inputs', 
            names=('param','input'), typenames=('type',),),
        TypedField('outputs', label='Outputs', 
            names=('out','output'), typenames=('type',),),

    ]

    def handle_signature(self, sig, signode):
        signode['name'] = sig
        signode += addnodes.desc_name(text=sig)
        return sig


    def add_target_and_index(self, name_cls, sig, signode):
        node_id = 'routine-'+sig
        signode['ids'].append(node_id)
        irbem = self.env.get_domain('irbem')
        irbem.add_routine(sig)
        self.indexnode['entries'].append(('single', sig, node_id, '',
            sig[0].upper()))

    def _toc_entry_name(self, signode):
        return signode['name']
    
    def _object_hierarchy_parts(self, signode):
        return (self._toc_entry_name(signode),)

class RoutineIndex(Index):
    """A custom index that creates an routine matrix."""

    name = 'routines'
    localname = 'Routines Index'
    shortname = 'Routine'

    def generate(self, docnames=None):
        content = defaultdict(list)
        # sort the list of recipes in alphabetical order
        routines = self.domain.get_objects()
        routines = sorted(set(routines), key=lambda routine: routine[0])

        # generate the expected output, shown below, from the above using the
        # first letter of the recipe as a key to group thing
        #
        # name, subtype, docname, anchor, extra, qualifier, description
        for _name, dispname, typ, docname, anchor, _priority in routines:
            content[dispname[0].upper()].append((
                dispname,
                0,
                docname,
                anchor,
                docname,
                '',
                typ,
            ))
        # convert the dict to the sorted list of tuples expected
        content = sorted(content.items())
        return content, True

class IRBEMDomain(Domain):
    name = 'irbem'
    label = 'IrbemLabel'
    roles = {
        'ref': XRefRole(),
    }
    directives = {
        'routine': RoutineDirective,
    }
    indices = {
        RoutineIndex,
    }
    initial_data = {
        'routines': [],  # object list
    }

    def get_full_qualified_name(self, node):
        return f'routine.{node.arguments[0]}'

    def get_objects(self):
        yield from self.data['routines']

    def resolve_xref(self, env, fromdocname, builder, typ, target, node, contnode):
        match = [
            (docname, anchor)
            for name, sig, typ, docname, anchor, prio in self.get_objects()
            if sig.upper() == target.upper()
        ]

        if len(match) > 0:
            todocname = match[0][0]
            targ = match[0][1]

            return make_refnode(builder, fromdocname, todocname, targ, contnode, targ)
        else:
            print('Awww, found nothing')
            return None

    def add_routine(self, signature):
        """Add a new routine to the domain."""
        name = f'routine.{signature}'
        anchor = f'routine-{signature}'

        # name, dispname, type, docname, anchor, priority
        self.data['routines'].append((name, signature, 'Routine', self.env.docname, anchor, 0))

def setup(app: Sphinx):
    app.add_domain(IRBEMDomain)
    return {
        'version': '0.1',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    }
