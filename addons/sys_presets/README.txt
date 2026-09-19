ALiVE Presets

Sharing an ALiVE setup as a preset: one line of plain text carrying every ALiVE
module in a scenario, the settings that were actually chosen, and the sync lines
between them. Right click any ALiVE module in the editor and use Share as preset
under the ALiVE folder.

A preset is data, never code. It is read back with parseSimpleArray, which cannot
run what it reads, and the one module setting that holds script is never carried.
Settings naming something that exists only in the scenario it came from, such as
an area marker, are left out and named in the message so nobody is surprised.

Only settings that differ from a module's own default go in, which is what keeps a
preset a few hundred characters and lets a default improved later reach a preset
written today.
