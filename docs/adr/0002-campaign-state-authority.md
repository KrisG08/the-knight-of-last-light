# One durable campaign authority

Status: proposed implementation baseline.

CampaignState is the authority for permanent progression, and semantic actions update it with rewards as one logical transaction. Runtime scenes derive gates, recruited NPCs and defeated bosses from that state. This avoids convenient but contradictory scene-local permanent flags and makes save/load behavior testable. Immediate combat stays in engine-native runtime state; do not send every sword hit through a persistent campaign event log.
