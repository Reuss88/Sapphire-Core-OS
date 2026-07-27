begin;

alter table sca_meta.lifecycle_definition enable row level security;

create policy lifecycle_definition_select_all
on sca_meta.lifecycle_definition
for select
to authenticated
using (true);

comment on policy lifecycle_definition_select_all is
  'Allow authenticated users to read lifecycle definitions (metadata).';

commit;
